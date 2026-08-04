{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.services;
in
{
  imports = [
    inputs.cliproxyapi.nixosModules.default
  ];

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

    cliproxyapi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "CLIProxyAPI service (Claude Code harness for GPT-5.6 Sol)";
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

      (lib.mkIf cfg.cliproxyapi {
        services.cliproxyapi = {
          enable = true;
          configFile = ../../configs/cliproxyapi/config.yaml;
        };
      })

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
