{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

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
      obs = true;
      obsCuda = true;
    };
  };

  services.usbmuxd.enable = true;

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
