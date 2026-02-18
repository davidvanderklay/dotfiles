{ config, lib, pkgs, inputs, ... }:

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

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
