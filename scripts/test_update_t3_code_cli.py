import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "updater", Path(__file__).with_name("update-t3-code-cli.py")
)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


def release(version, *, draft=False, asset=True):
    return {
        "tag_name": f"v{version}",
        "draft": draft,
        "assets": [{
            "name": f"t3-{version}-linux-x64.tar.gz",
            "state": "uploaded",
        }] if asset else [],
    }


class NightlyUpdateTests(unittest.TestCase):
    def test_selects_newest_nightly_with_cli_across_unordered_pages(self):
        versions = [
            release("0.0.45-nightly.20261002.9"),
            release("0.0.46-preview.20261002.100"),
            release("0.0.46"),
            release("0.0.45-nightly.20261002.100", draft=True),
            release("0.0.45-nightly.20261002.99", asset=False),
            release("0.0.45-nightly.20261002.10"),
        ]
        self.assertEqual(updater.latest_nightly(versions)[0], "0.0.45-nightly.20261002.10")

    def test_fails_when_no_nightly_cli_exists(self):
        with self.assertRaisesRegex(ValueError, "No published nightly"):
            updater.latest_nightly([release("0.0.45")])

    def test_unchanged_or_older_release_does_not_download_or_rewrite(self):
        source = 'version = "0.0.45-nightly.20261002.10";\nhash = "sha256-old";\n'
        with tempfile.TemporaryDirectory() as directory:
            package = Path(directory) / "default.nix"
            package.write_text(source)
            with patch.object(updater.subprocess, "run") as download:
                for version in ["0.0.45-nightly.20261002.10", "0.0.45-nightly.20261002.9"]:
                    updater.update_package(package, version, {})
                download.assert_not_called()
            self.assertEqual(package.read_text(), source)

    def test_digest_mismatch_leaves_pin_untouched(self):
        source = 'version = "0.0.43-nightly.20260926.2318";\nhash = "sha256-old";\n'
        with tempfile.TemporaryDirectory() as directory:
            package = Path(directory) / "default.nix"
            package.write_text(source)
            with patch.object(updater.subprocess, "run") as download:
                download.return_value.stdout = '{"hash": "sha256-wrong"}'
                with self.assertRaisesRegex(ValueError, "does not match"):
                    updater.update_package(package, "0.0.45-nightly.20261002.10", {
                        "browser_download_url": "https://example.com/archive",
                        "digest": "sha256:" + "00" * 32,
                    })
            self.assertEqual(package.read_text(), source)


if __name__ == "__main__":
    unittest.main()
