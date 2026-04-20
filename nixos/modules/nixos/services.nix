{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.services;
in
{
  options.mymod.services = {
    enable = lib.mkEnableOption "common services (tailscale, flatpak)";

    tailscale = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    flatpak = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.tailscale.enable = cfg.tailscale;
        services.flatpak.enable = cfg.flatpak;
      }

      (lib.mkIf cfg.openFirewall {
        networking.firewall.allowedTCPPorts = [
          53317
          8081
        ];
        networking.firewall.allowedUDPPorts = [
          53317
          8081
        ];
      })
    ]
  );
}