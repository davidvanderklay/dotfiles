{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.docker;
in
{
  options.mySystem.services.docker.enable = lib.mkEnableOption "Docker Virtualization";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      # Automatically clean up old images/containers weekly
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Automatically add your user to the docker group
    users.users.geolan.extraGroups = [ "docker" ];
  };
}
