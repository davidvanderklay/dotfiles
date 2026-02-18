{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
    ../../modules/nixos
  ];

  mymod = {
    core = {
      enable = true;
      hostName = "nixos-laptop";
    };
    
    desktop.enable = true;
    gaming.enable = true;
    docker.enable = true;
    
    nvidia = {
      enable = true;
      laptop = {
        enable = true;
        amdgpuBusId = "PCI:7:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    
    services.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.asusd = {
    enable = true;
    enableUserService = true;
  };
}
