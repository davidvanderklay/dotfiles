{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mymod.home.t3Code;
in
{
  options.mymod.home.t3Code.enable = lib.mkEnableOption "T3 Code desktop app and URL handler";

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.t3code-flake.packages.${pkgs.stdenv.hostPlatform.system}.t3-code-nightly
    ];

    # GUI apps started from a shell need the session's Wayland and DBus variables.
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
      Install.WantedBy = [ "graphical-session.target" ];
    };

    xdg.desktopEntries.t3-code-url-handler = {
      name = "T3 Code URL Handler";
      exec = "t3 %U";
      terminal = false;
      noDisplay = true;
      mimeType = [ "x-scheme-handler/t3code" ];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications."x-scheme-handler/t3code" = "t3-code-url-handler.desktop";
    };
  };
}
