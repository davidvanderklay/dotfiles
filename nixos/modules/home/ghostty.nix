{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.mymod.home.ghostty;
  configsPath = ../../configs;
in
{
  options.mymod.home.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal configuration";

    enableService = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = false;
      installBatSyntax = false;
    };

    xdg.configFile."ghostty/config".source = "${configsPath}/ghostty/config";

    xdg.dataFile."applications/com.mitchellh.ghostty.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Name=Ghostty
      Type=Application
      Comment=A terminal emulator
      TryExec=${lib.getExe pkgs.ghostty}
      Exec=${lib.getExe pkgs.ghostty}
      Icon=com.mitchellh.ghostty
      Categories=System;TerminalEmulator;
      Keywords=terminal;tty;pty;
      StartupNotify=true
      StartupWMClass=com.mitchellh.ghostty
      Terminal=false
      Actions=new-window;
      X-GNOME-UsesNotifications=true
      X-TerminalArgExec=-e
      X-TerminalArgTitle=--title=
      X-TerminalArgAppId=--class=
      X-TerminalArgDir=--working-directory=
      X-TerminalArgHold=--wait-after-command
      X-KDE-Shortcuts=Ctrl+Alt+T

      [Desktop Action new-window]
      Name=New Window
      Exec=${lib.getExe pkgs.ghostty}
    '';

    systemd.user.services = lib.mkIf cfg.enableService {
      ghostty = {
        Unit = {
          Description = "Ghostty Terminal Server";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.ghostty} --initial-window=false";
          Restart = "on-failure";
          KillMode = "process";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      dbus-update-activation-environment = {
        Unit = {
          Description = "Update DBus activation environment";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
