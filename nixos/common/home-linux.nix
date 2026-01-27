{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./home-core.nix
    ./gnome.nix # <--- Add this line near the top
  ];

  home.username = "geolan";
  home.homeDirectory = "/home/geolan";

  home.packages = with pkgs; [

    distrobox
    pkgs.localsend

    # Gaming
    lutris
    heroic
    r2modman
    prismlauncher
    protonplus
    ludusavi
    # sgdboop

    # Social
    bitwarden-desktop
    vesktop

    # Wine stuff
    wineWow64Packages.stable
    winetricks

    ungoogled-chromium

  ];

  # 1. GHOSTTY CONFIGURATION
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # We link your config file from the dotfiles directory
    installBatSyntax = false; # Fixes a common conflict issue
  };

  systemd.user.services.ghostty = {
    Unit = {
      Description = "Ghostty Terminal Server";
      # Wait for the desktop to load before starting
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      # We explicitly use the nix package path so it never fails to find the binary
      ExecStart = "${lib.getExe pkgs.ghostty} --initial-window=false";

      # If it crashes, restart it automatically
      Restart = "on-failure";

      # "process" means: when we kill the window, don't kill the daemon
      KillMode = "process";
    };

    Install = {
      # This effectively "enables" it at login
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.dbus-update-activation-environment = {
    Unit = {
      Description = "Update DBus activation environment";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.ludusavi-backup = {
    Unit.Description = "Ludusavi Auto Backup with Cloud Sync";
    Service = {
      # This backs up locally FIRST, then UPLOADS to the cloud
      ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force --cloud-sync";
      Type = "oneshot";
    };
  };

  systemd.user.timers.ludusavi-auto-backup = {
    Timer.OnCalendar = "daily";
    Timer.Persistent = true;
    Install.WantedBy = [ "timers.target" ];
  };

  # Link the config file manually to ensure it uses your specific file
  xdg.configFile."ghostty/config".source = ./ghostty/config;

  home.stateVersion = "25.11";
}
