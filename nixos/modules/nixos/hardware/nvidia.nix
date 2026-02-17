{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "Nvidia Drivers";

  config = lib.mkIf config.mySystem.hardware.nvidia.enable {
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
      powerManagement.enable = true;
      open = true; # Use the GSP modules
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
