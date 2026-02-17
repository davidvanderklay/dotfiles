{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHome.gaming;
in
{
  options.myHome.gaming.enable = lib.mkEnableOption "User-level gaming apps";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris
      heroic
      r2modman
      prismlauncher
      protonplus
      ludusavi
      wineWow64Packages.stable
      winetricks
    ];

    # Your Ludusavi Backup Service logic moves here!
    systemd.user.services.ludusavi-backup = {
      Unit.Description = "Ludusavi Auto Backup with Cloud Sync";
      Service = {
        ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force --cloud-sync";
        Type = "oneshot";
      };
    };

    systemd.user.timers.ludusavi-auto-backup = {
      Timer.OnCalendar = "daily";
      Timer.Persistent = true;
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
