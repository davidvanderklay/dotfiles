{
  config,
  lib,
  ...
}:

let
  cfg = config.mymod.nixos.gaming;
in
{
  options.mymod.nixos.gaming = {
    enable = lib.mkEnableOption "gaming packages and configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
