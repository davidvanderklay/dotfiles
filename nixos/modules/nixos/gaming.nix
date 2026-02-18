{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.gaming;
in
{
  options.mymod.gaming = {
    enable = lib.mkEnableOption "gaming packages and configuration";

    enableOsu = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enableHonkers = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages =
      with pkgs;
      lib.optionals cfg.enableOsu [
        inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
      ];

    nix.settings = lib.mkIf cfg.enableHonkers inputs.aagl.nixConfig;
    programs.honkers-railway-launcher.enable = cfg.enableHonkers;
  };
}
