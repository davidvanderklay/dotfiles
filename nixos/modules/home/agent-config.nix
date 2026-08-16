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

    # Codex uses AGENTS.md directly for global guidance.
    ".codex/AGENTS.md".source = linkFromRepo "AGENTS.md";

    # Link individual skills so existing user skills, such as find-skills,
    # remain in ~/.agents/skills alongside the shared skills.
    ".agents/skills/babysit-pr".source = linkFromRepo "skills/babysit-pr";
    ".agents/skills/file-pr".source = linkFromRepo "skills/file-pr";
    ".agents/skills/file-upload".source = linkFromRepo "skills/file-upload";
    ".agents/skills/grill-me".source = linkFromRepo "skills/grill-me";
    ".agents/skills/grilling".source = linkFromRepo "skills/grilling";
    ".agents/skills/handoff".source = linkFromRepo "skills/handoff";
    ".agents/skills/html-communication".source = linkFromRepo "skills/html-communication";
    ".agents/skills/postplan-read".source = linkFromRepo "skills/postplan-read";
    ".agents/skills/review-pr".source = linkFromRepo "skills/review-pr";
    ".agents/skills/to-spec".source = linkFromRepo "skills/to-spec";
    ".agents/skills/to-tickets".source = linkFromRepo "skills/to-tickets";
  };
}
