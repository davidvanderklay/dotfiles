{ config, pkgs, lib, ... }:

let
  cfg = config.mymod.home.gaming;
in
{
  options.mymod.home.gaming = {
    enable = lib.mkEnableOption "gaming home packages";
    
    enableLudusaviBackup = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      distrobox
      localsend
      lutris
      heroic
      r2modman
      prismlauncher
      protonplus
      ludusavi
      bitwarden-desktop
      vesktop
      wineWow64Packages.stable
      winetricks
      ungoogled-chromium
    ];

    systemd.user.services.ludusavi-backup = lib.mkIf cfg.enableLudusaviBackup {
      Unit.Description = "Ludusavi Auto Backup with Cloud Sync";
      Service = {
        ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force --cloud-sync";
        Type = "oneshot";
      };
    };

    systemd.user.timers.ludusavi-auto-backup = lib.mkIf cfg.enableLudusaviBackup {
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
