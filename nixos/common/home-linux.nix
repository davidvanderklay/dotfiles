{ config, pkgs, ... }:

{
  imports = [
    ./home-core.nix
    ./gnome.nix # <--- Add this line near the top
  ];

  home.username = "geolan";
  home.homeDirectory = "/home/geolan";

  home.packages = with pkgs; [

    distrobox

    # Gaming
    lutris
    heroic
    r2modman
    prismlauncher
    protonplus
    ludusavi

    # Social
    bitwarden-desktop
    vesktop

    # Wine stuff
    wineWow64Packages.stable
    winetricks

    ungoogled-chromium

  ];

  # 1. GHOSTTY CONFIGURATION
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # We link your config file from the dotfiles directory
    installBatSyntax = false; # Fixes a common conflict issue
  };

  # Link the config file manually to ensure it uses your specific file
  xdg.configFile."ghostty/config".source = ./ghostty/config;

  home.stateVersion = "25.11";
}
