{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.docker;
in
{
  options.mymod.docker = {
    enable = lib.mkEnableOption "Docker and auto-prune";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };
  };
}
