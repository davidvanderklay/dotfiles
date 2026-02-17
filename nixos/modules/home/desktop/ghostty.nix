{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHome.desktop.ghostty;
in
{
  options.myHome.desktop.ghostty.enable = lib.mkEnableOption "Ghostty Terminal";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = false;
    };

    # Link the config from your dotfiles (Relative path to your ghostty/config)
    xdg.configFile."ghostty/config".source = ../../../common/ghostty/config;

    # The Ghostty Daemon service you had in home-linux.nix
    systemd.user.services.ghostty = {
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
  };
}
