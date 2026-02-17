{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    # Global aliases or settings that you want on EVERY machine
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.lazygit.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
