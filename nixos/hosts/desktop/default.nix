{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core/default.nix # Locales, GC, Nix settings
    ../../modules/nixos/core/boot.nix # Lanzaboote logic
    ../../modules/nixos/hardware/nvidia.nix # Nvidia drivers & env vars
    ../../modules/nixos/services/audio.nix # Pipewire/Pipewire-32bit
    ../../modules/nixos/services/docker.nix # Docker + User Groups
    ../../modules/nixos/services/localsend.nix # LocalSend + Firewall
    ../../modules/nixos/desktop/gnome.nix # GDM + GNOME Service
    ../../modules/nixos/gaming/default.nix # Steam/Infrastructure
    ../../modules/nixos/gaming/aagl.nix # Anime Game Launcher
    ../../modules/nixos/gaming/osu.nix # Osu!
  ];

  # Boot & Hardware
  mySystem.boot.secureboot.enable = true;
  mySystem.hardware.nvidia.enable = true;

  # Desktop Environment
  mySystem.desktop.gnome.enable = true;

  # Services
  mySystem.services.docker.enable = true;
  mySystem.services.localsend.enable = true;

  # Gaming
  mySystem.gaming.platform.enable = true; # Steam/Gamemode
  mySystem.gaming.aagl.enable = true; # Honkai Star Rail
  mySystem.gaming.osu.enable = true; # Osu!

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # --- FIX FOR SLOW APP STARTUP ---
  xdg.portal = {
    enable = true;

    # Ensure the GNOME portal is installed and ready
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];

    # Force apps to use the GNOME portal
    config.common.default = "gnome";
  };
}
