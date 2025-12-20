{
  config,
  pkgs,
  lib,
  ...
}:
let
  # 1. Define the custom wrapper script right here
  # This creates a command called 'osu' that automatically applies low latency and gamemode
  osu-optimized = pkgs.writeShellScriptBin "osu" ''
    export PIPEWIRE_LATENCY="64/48000" 
    # Use gamemoderun to launch the official binary
    exec ${pkgs.gamemode}/bin/gamemoderun ${pkgs.osu-lazer-bin}/bin/osu! "$@"
  '';
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos-desktop";

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Specific drivers (like Nvidia) go here
  # services.xserver.videoDrivers = [ "nvidia" ];
  # 1. Load the Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # 2. Enable OpenGL (renamed to hardware.graphics in recent unstable)
  hardware.graphics = {
    enable = true;
    # IMPORTANT: Enable 32-bit support for Steam to work!
    enable32Bit = true;
  };

  # 3. Configure the Nvidia settings
  hardware.nvidia = {
    # Modesetting is required for most Wayland compositors (Hyprland, Gnome, etc.)
    modesetting.enable = true;

    # Power management (fine-grained is usually for laptops, can leave false for desktop)
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # USE THE OPEN KERNEL MODULES (GSP)
    # Supported on your RTX 3060 Ti.
    open = true;

    # Enable the Nvidia settings menu (accessible via 'nvidia-settings')
    nvidiaSettings = true;

    # Select the driver version
    # 'stable' is usually best, but you can use 'beta' or 'production'
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Ensure these are in hardware.graphics
  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
    libvdpau-va-gl
  ];

  # Realtime audio priority
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # Optional
  };

  # 3. Install the specific package + the wrapper
  environment.systemPackages = with pkgs; [
    osu-optimized # This installs our custom script above
    osu-lazer-bin # This installs the actual game assets
    pavucontrol # Audio control
  ];

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
