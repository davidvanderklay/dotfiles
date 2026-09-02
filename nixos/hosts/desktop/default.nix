{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  mymod.nixos = {
    core = {
      enable = true;
      hostName = "nixos-desktop";
    };

    gnome.enable = true;
    gaming.enable = true;
    docker.enable = true;

    nvidia.enable = true;

    services = {
      enable = true;
    };
  };

  services.usbmuxd.enable = true;

  services.udev.extraRules = ''
    # General USB/HID access for WebUSB/WebHID (Wootility, VIA, Rawm, SayoDevice, etc.)
    SUBSYSTEM=="hidraw", TAG+="uaccess"
  '';

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Android Studio is a desktop-only workstation tool, not a generic
  # system package. Laptop does not install it.
  nixpkgs.config.android_sdk.accept_license = true;

  environment.systemPackages = with pkgs; [
    android-studio
    usbmuxd
    sbctl
    nicotine-plus
    feishin
    imagemagick
    ghostscript
  ];

  # Secure boot via lanzaboote. systemd-boot is disabled on purpose;
  # configurationLimit below only applies if you re-enable systemd-boot.
  # pkiBundle assumes `sbctl create-keys` was run once manually.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

}
