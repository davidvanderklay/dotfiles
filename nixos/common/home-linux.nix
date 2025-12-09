
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


  home.stateVersion = "25.11";
}
