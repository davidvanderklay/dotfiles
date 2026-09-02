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
      description = "Run Ghostty as a graphical-session server for fast opens.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        # Bat syntax files duplicate what Ghostty already ships; skip them.
        installBatSyntax = false;
      };

      xdg.configFile."ghostty/config".source = "${configsPath}/ghostty/config";
    })

    # Server keeps one process around so new windows open instantly.
    # The generic DBus env fix lives in workstation.nix, not here, so
    # disabling Ghostty does not break other graphical apps.
    (lib.mkIf (cfg.enable && cfg.enableService) {
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
    })
  ];
}
