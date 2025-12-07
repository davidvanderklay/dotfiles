{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos-desktop"; 
  
  # Specific drivers (like Nvidia) go here
  # services.xserver.videoDrivers = [ "nvidia" ];
}
