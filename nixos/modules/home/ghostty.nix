{ config, pkgs, lib, ... }:

let
  cfg = config.mymod.home.ghostty;
  configsPath = ../../../configs;
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
      enableZshIntegration = true;
      installBatSyntax = false;
    };

    xdg.configFile."ghostty/config".source = "${configsPath}/ghostty/config";

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
