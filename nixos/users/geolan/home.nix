{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/home/shell
    ../../modules/home/editors/nixvim.nix
    # ../../modules/home/desktop/ghostty.nix
    # ../../modules/home/gaming.nix
    # ../../modules/home/desktop/gnome.nix
  ];

  # NOW YOU JUST TOGGLE THINGS ON OR OFF
  # myHome.gaming.enable = pkgs.stdenv.isLinux; # Enable gaming only on Linux
  # myHome.desktop.ghostty.enable = true;
  # myHome.desktop.gnome.enable = true;
  myHome.editors.nixvim.enable = true;
  myHome.shell.enable = true;

  programs.git = {
    # "settings" replaces userName, userEmail, and extraConfig
    settings = {
      user = {
        name = "davidvanderklay";
        email = "davidvanderklay@gmail.com";
      };
      # Any other config goes here, e.g.:
      # init.defaultBranch = "main";
      # core.editor = "nvim";
    };
  };
  # ... rest of your git/direnv settings ...
}
