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

    obs = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    obsCuda = lib.mkOption {
      type = lib.types.bool;
      default = false;
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

      (lib.mkIf cfg.obs {
        programs.obs-studio = {
          enable = true;
          package = if cfg.obsCuda then pkgs.obs-studio.override { cudaSupport = true; } else pkgs.obs-studio;
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-backgroundremoval
            obs-pipewire-audio-capture
            obs-vaapi
            obs-gstreamer
            obs-vkcapture
          ];
        };
      })
    ]
  );
}
