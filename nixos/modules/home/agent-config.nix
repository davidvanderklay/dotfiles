{ config, lib, ... }:

let
  cfg = config.mymod.home.agentConfig;
  agentConfigRepo = "${config.home.homeDirectory}/Projects/agent-config";
  linkFromRepo = path: config.lib.file.mkOutOfStoreSymlink "${agentConfigRepo}/${path}";
in
{
  options.mymod.home.agentConfig = {
    enable = lib.mkEnableOption "symlinks into the separate agent-config repo" // {
      default = true;
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
  };
}
