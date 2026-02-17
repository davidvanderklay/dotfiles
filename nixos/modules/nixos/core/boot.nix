{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mySystem.boot.secureboot.enable = lib.mkEnableOption "Lanzaboote Secure Boot";

  config = lib.mkIf config.mySystem.boot.secureboot.enable {
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
