{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.mymod.home.gaming;
  # Adds middle-click autoscroll, which Helium disables by default.
  # Fragile by nature: uses --replace-fail so the build breaks loudly
  # if upstream renames the WaylandWindowDecorations flag. Fix by
  # updating the flag strings below, not by removing --replace-fail.
  helium = inputs.helium.packages."${pkgs.stdenv.hostPlatform.system}".default.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/bin/helium \
        --replace-fail \
        '--enable-features=WaylandWindowDecorations' \
        '--enable-features=WaylandWindowDecorations,HeliumMiddleClickAutoscroll'
    '';
  });
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
      heroic
      r2modman
      prismlauncher
      protonplus
      ludusavi
      vesktop
      wineWow64Packages.stable
      winetricks
      helium
    ];

    systemd.user.services.ludusavi-backup = lib.mkIf cfg.enableLudusaviBackup {
      Unit.Description = "Ludusavi Auto Backup with Cloud Sync";
      Service = {
        ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force --cloud-sync";
        Type = "oneshot";
      };
    };

    systemd.user.timers.ludusavi-backup = lib.mkIf cfg.enableLudusaviBackup {
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
