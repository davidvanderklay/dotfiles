{
  config,
  lib,
  ...
}:

let
  cfg = config.mymod.nixos.docker;
in
{
  options.mymod.nixos.docker = {
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
