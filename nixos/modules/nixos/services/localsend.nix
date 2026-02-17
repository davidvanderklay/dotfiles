{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mySystem.services.localsend;
in
{
  options.mySystem.services.localsend.enable = lib.mkEnableOption "LocalSend File Sharing";

  config = lib.mkIf cfg.enable {
    # Install the package at the system level
    environment.systemPackages = [ pkgs.localsend ];

    # Open the specific ports LocalSend needs in the firewall
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
