{
  config,
  pkgs,
  lib,
  ...
}:
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
}
