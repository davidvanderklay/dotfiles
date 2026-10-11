{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.nixos.gaming;
in
{
  options.mymod.nixos.gaming = {
    enable = lib.mkEnableOption "gaming packages and configuration";

    enableOsu = lib.mkOption {
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
  };
}
