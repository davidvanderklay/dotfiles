{ config, ... }:

let
  agentConfigRepo = "${config.home.homeDirectory}/Projects/agent-config";
  linkFromRepo = path:
    config.lib.file.mkOutOfStoreSymlink "${agentConfigRepo}/${path}";
in
{
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
  };
}
