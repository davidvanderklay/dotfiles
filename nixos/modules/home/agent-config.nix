{ config, lib, pkgs, ... }:

let
  cfg = config.mymod.home.agentConfig;
  agentConfigRepo = toString cfg.repoPath;
  linkFromRepo = path: config.lib.file.mkOutOfStoreSymlink "${agentConfigRepo}/${path}";
  hermesServerHealthWrapper = pkgs.writeShellScript "hermes-server-health-wrapper" ''
    exec "${agentConfigRepo}/hermes/scripts/server-health.sh" "$@"
  '';
  hermesGithubPrWrapper = pkgs.writeShellScript "hermes-github-pr-wrapper" ''
    exec "${agentConfigRepo}/hermes/scripts/github-pr-status.sh" "$@"
  '';
in
{
  options.mymod.home.agentConfig = {
    enable = lib.mkEnableOption "symlinks into the separate agent-config repo" // {
      default = true;
    };

    repoPath = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/Projects/agent-config";
      description = "Checkout containing shared agent instructions and skills";
    };
  };

  config = lib.mkIf cfg.enable {
    # Keep the source of truth in the separate agent-config repository. These
    # links intentionally point outside the Nix store so edits take effect
    # without rebuilding Home Manager.
    home.file = {
      ".claude/CLAUDE.md".source = linkFromRepo "CLAUDE.md";
      ".claude/agents".source = linkFromRepo "agents";
      ".claude/rules".source = linkFromRepo "rules";
      ".claude/skills" = {
        source = linkFromRepo "skills";
        # Claude created this empty directory before Home Manager managed it.
        force = true;
      };

      # Codex uses AGENTS.md directly for global guidance.
      ".codex/AGENTS.md".source = linkFromRepo "AGENTS.md";

      # Hermes keeps runtime state and credentials under ~/.hermes, while
      # these mutable, non-secret inputs live in the Git checkout.
      ".hermes/config.yaml" = {
        source = linkFromRepo "hermes/config.yaml";
        force = true;
      };
      ".hermes/SOUL.md" = {
        source = linkFromRepo "hermes/SOUL.md";
        force = true;
      };
      ".hermes/monitored-repos" = {
        source = linkFromRepo "hermes/monitored-repos";
        force = true;
      };
    };

    # Discover shared skills at activation time. The repository is intentionally
    # outside the flake, so reading it during pure Nix evaluation is forbidden.
    # Existing non-symlinked local skills are left untouched. Skips quietly
    # when the repo is not checked out (e.g. generic/containers).
    home.activation.linkAgentConfigSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      skills_dir="${agentConfigRepo}/skills"
      target_dir="$HOME/.agents/skills"

      [ -d "$skills_dir" ] || exit 0
      mkdir -p "$target_dir"
      for skill_dir in "$skills_dir"/*; do
        [ -d "$skill_dir" ] || continue
        skill_name="''${skill_dir##*/}"
        target="$target_dir/$skill_name"

        if [ -L "$target" ]; then
          rm "$target"
        elif [ -e "$target" ]; then
          echo "Skipping shared skill '$skill_name': $target already exists" >&2
          continue
        fi

        ln -s "$skill_dir" "$target"
      done
    '';

    # ~/.hermes is also a runtime directory, so Home Manager can leave
    # pre-existing files there untouched even when a home.file entry has
    # force = true. Link the Git-owned Hermes inputs explicitly after the
    # generation has been linked. Runtime state and credentials remain local.
    home.activation.linkHermesAgentConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      hermes_source="${agentConfigRepo}/hermes"
      hermes_target="$HOME/.hermes"

      [ -d "$hermes_source" ] || exit 0
      mkdir -p "$hermes_target/scripts"

      for relative_path in \
        config.yaml \
        SOUL.md \
        monitored-repos; do
        source_path="$hermes_source/$relative_path"
        target_path="$hermes_target/$relative_path"

        [ -e "$source_path" ] || continue
        if [ -L "$target_path" ] || [ -f "$target_path" ]; then
          rm -f "$target_path"
        elif [ -e "$target_path" ]; then
          echo "Skipping Hermes config '$relative_path': target is not a file" >&2
          continue
        fi

        ln -s "$source_path" "$target_path"
      done

      # Hermes resolves cron scripts before running them and rejects symlinks
      # whose targets leave ~/.hermes/scripts. Keep the source scripts in Git,
      # but place regular wrappers in Hermes' allowed directory.
      for script_name in server-health.sh github-pr-status.sh; do
        source_path="$hermes_source/scripts/$script_name"
        target_path="$hermes_target/scripts/$script_name"

        [ -e "$source_path" ] || continue
        case "$script_name" in
          server-health.sh)
            wrapper_path="${hermesServerHealthWrapper}"
            ;;
          github-pr-status.sh)
            wrapper_path="${hermesGithubPrWrapper}"
            ;;
        esac

        if [ -L "$target_path" ] || [ -f "$target_path" ]; then
          rm -f "$target_path"
        elif [ -e "$target_path" ]; then
          echo "Skipping Hermes script '$script_name': target is not a file" >&2
          continue
        fi

        ${pkgs.coreutils}/bin/install -m 700 "$wrapper_path" "$target_path"
      done
    '';
  };
}
