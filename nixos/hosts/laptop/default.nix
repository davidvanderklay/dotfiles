{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos-laptop"; 
  
  # Specific drivers (like Nvidia) go here
  # services.xserver.videoDrivers = [ "nvidia" ];
   # --- GRAPHICS & NVIDIA ---
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # --- BATTERY OPTIMIZATION FOR GPU ---
    # This is distinct from CPU power. This turns off the Nvidia card
    # when you aren't playing games.
    powerManagement.enable = false; # Keep 'false' for offload mode
    powerManagement.finegrained = true; # <--- IMPORTANT: This puts GPU to sleep

    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # --- PRIME OFFLOAD ---
    prime = {
      # 1. RUN: nix shell nixpkgs#pciutils -c lspci | grep VGA
      # 2. Convert output (e.g. 01:00.0) to decimal (PCI:1:0:0)
      
      # Example IDs (YOU MUST CHANGE THESE TO MATCH YOUR LAPTOP):
      amdgpuBusId = "PCI:7:0:0"; 
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

    };
  };

  # --- ASUS SPECIFIC TOOLS ---
  # This enables the background daemon (asusd) and installs the 'asusctl' CLI tool.
  # It allows you to control RGB, fan curves, and battery charge limits.
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

}
