{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.services;

  # The service module from nix-cliproxyapi invokes /bin/cliproxyapi, while
  # Numtide's package keeps the upstream binary name /bin/cli-proxy-api.
  cliproxyapiPackage = pkgs.symlinkJoin {
    name = "cli-proxy-api-service";
    paths = [ inputs.llm-agents.packages.${pkgs.system}.cli-proxy-api ];
    postBuild = "ln -s $out/bin/cli-proxy-api $out/bin/cliproxyapi";
  };
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
        services.cliproxyapi.enable = true;
        services.cliproxyapi.package = cliproxyapiPackage;

        # Seed config.yaml as a real file (not a store symlink) so it can be
        # edited live — secrets like remote-management.secret-key stay out of
        # git. Only seeds if the file doesn't already exist; the module's own
        # preStart (which symlinks configFile) is replaced since we no longer
        # pass configFile.
        systemd.services.cliproxyapi.preStart = lib.mkForce ''
          mkdir -p ${config.services.cliproxyapi.dataDir}
          if [ ! -f ${config.services.cliproxyapi.dataDir}/config.yaml ]; then
            cp ${../../configs/cliproxyapi/config.yaml} ${config.services.cliproxyapi.dataDir}/config.yaml
            chown ${config.services.cliproxyapi.user}:${config.services.cliproxyapi.group} ${config.services.cliproxyapi.dataDir}/config.yaml
            chmod 600 ${config.services.cliproxyapi.dataDir}/config.yaml
          fi
        '';
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
