#!/usr/bin/env python3
"""Pin the standalone Linux CLI to the newest available nightly release."""

import base64
import json
from pathlib import Path
import re
import subprocess


PACKAGE = Path(__file__).resolve().parents[1] / "nixos/packages/t3-code-cli/default.nix"
NIGHTLY = re.compile(r"(\d+)\.(\d+)\.(\d+)-nightly\.(\d{8})\.(\d+)")


def version_key(version):
    match = NIGHTLY.fullmatch(version)
    if match is None:
        raise ValueError(f"Not a nightly version: {version}")
    return tuple(map(int, match.groups()))


def latest_nightly(releases):
    candidates = []
    for release in releases:
        version = release["tag_name"].removeprefix("v")
        if release["draft"] or not NIGHTLY.fullmatch(version):
            continue
        filename = f"t3-{version}-linux-x64.tar.gz"
        for asset in release["assets"]:
            if asset["name"] == filename and asset["state"] == "uploaded":
                candidates.append((version, asset))
                break
    if not candidates:
        raise ValueError("No published nightly with a Linux x64 CLI archive found")
    return max(candidates, key=lambda candidate: version_key(candidate[0]))


def update_package(package, version, asset):
    source = package.read_text()
    current = re.search(r'\bversion = "([^"]+)";', source).group(1)
    if version_key(version) <= version_key(current):
        print(f"Already current: {current}; newest available nightly: {version}")
        return

    # Prefetch the actual archive, using the same hash format as fetchurl.
    result = subprocess.run(
        ["nix", "store", "prefetch-file", "--json", asset["browser_download_url"]],
        check=True,
        capture_output=True,
        text=True,
    )
    archive_hash = json.loads(result.stdout)["hash"]
    digest = asset.get("digest")
    if digest:
        expected = "sha256-" + base64.b64encode(
            bytes.fromhex(digest.removeprefix("sha256:"))
        ).decode()
        if archive_hash != expected:
            raise ValueError("Downloaded archive does not match GitHub's SHA256 digest")

    source, version_count = re.subn(
        r'\bversion = "[^"]+";', f'version = "{version}";', source
    )
    source, hash_count = re.subn(
        r'\bhash = "[^"]+";', f'hash = "{archive_hash}";', source
    )
    if (version_count, hash_count) != (1, 1):
        raise ValueError("Expected exactly one version and one hash in the CLI package")
    package.write_text(source)
    print(f"Updated T3 Code CLI: {current} -> {version}")


def main():
    result = subprocess.run(
        [
            "gh", "api", "--paginate", "--slurp",
            "repos/pingdotgg/t3code/releases?per_page=100",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    releases = [release for page in json.loads(result.stdout) for release in page]
    version, asset = latest_nightly(releases)
    update_package(PACKAGE, version, asset)


if __name__ == "__main__":
    main()
