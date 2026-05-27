{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  mymod = {
    core = {
      enable = true;
      hostName = "nixos-desktop";
    };

    desktop.enable = true;
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

  environment.systemPackages = with pkgs; [
    usbmuxd
    sbctl
    nicotine-plus
    feishin
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
