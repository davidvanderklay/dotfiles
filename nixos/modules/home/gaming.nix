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
  # nixpkgs 740730748ec2 made GTK's `-lz` link libz.so, but localsend_app's
  # rpath lacks zlib, so it fails at launch. Drop once upstream fixes it.
  localsend = pkgs.symlinkJoin {
    name = "localsend-zlib-fix";
    paths = [ pkgs.localsend ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/localsend_app \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.zlib ]}
    '';
  };
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
      r2modman
      prismlauncher
      protonplus
      ludusavi
      vesktop
      wineWow64Packages.stable
      winetricks
      helium
      inputs.irori.packages.${pkgs.stdenv.hostPlatform.system}.default
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
