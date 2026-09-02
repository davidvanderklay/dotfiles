{
  config,
  lib,
  ...
}:

let
  cfg = config.mymod.nixos.services;
in
{
  options.mymod.nixos.services = {
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

      # 53317 = LocalSend, 8081 = Feishin/Navidrome companion.
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
