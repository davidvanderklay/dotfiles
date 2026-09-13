{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.mymod.home.ghostty;
  configsPath = ../../configs;
  ghosttyConfig = builtins.readFile "${configsPath}/ghostty/config";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.mymod.home.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal configuration";

    enableService = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run Ghostty as a graphical-session server for fast opens.";
    };

    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 13;
      description = "Ghostty font size.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ghostty = {
        # macOS installs Ghostty through Homebrew because the nixpkgs package
        # is not available for Darwin at this revision.
        enable = !isDarwin;
        enableZshIntegration = !isDarwin;
        # Bat syntax files duplicate what Ghostty already ships; skip them.
        installBatSyntax = false;
      };

      # Keep the Vague OLED palette in one file while allowing macOS to use
      # the larger font from the standalone Mac config.
      xdg.configFile."ghostty/config".text = lib.replaceStrings
        [ "font-size = 13" ]
        [ "font-size = ${toString cfg.fontSize}" ]
        ghosttyConfig;
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
