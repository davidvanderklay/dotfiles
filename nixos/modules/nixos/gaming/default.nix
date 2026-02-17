{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mySystem.gaming.platform.enable = lib.mkEnableOption "Gaming Platform (Steam/Gamemode)";

  config = lib.mkIf config.mySystem.gaming.platform.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    hardware.graphics.enable32Bit = true; # Necessary for Steam
  };
}
