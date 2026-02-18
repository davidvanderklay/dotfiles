{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.nvidia;
in
{
  options.mymod.nvidia = {
    enable = lib.mkEnableOption "NVIDIA graphics driver";

    laptop = {
      enable = lib.mkEnableOption "NVIDIA laptop configuration with Prime offload";

      amdgpuBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:7:0:0";
      };

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
      };
    };

    package = lib.mkOption {
      type = lib.types.raw;
      default = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = cfg.package;

      powerManagement = {
        enable = !cfg.laptop.enable;
        finegrained = cfg.laptop.enable;
      };

      prime = lib.mkIf cfg.laptop.enable {
        amdgpuBusId = cfg.laptop.amdgpuBusId;
        nvidiaBusId = cfg.laptop.nvidiaBusId;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    environment.variables = {
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
}
