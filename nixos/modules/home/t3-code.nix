{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.home.t3Code;

  # Installs the headless server with upstream's installer. After that,
  # `t3 service install` owns t3code.service and `t3 update` replaces it.
  t3CodeInstall = pkgs.writeShellApplication {
    name = "t3code-install";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      findutils
      gnugrep
      gnused
      gnutar
      gzip
      systemd
    ];
    text = ''
      curl -fsSL https://t3.codes/install.sh | T3CODE_CHANNEL=${cfg.channel} sh
      "$HOME/.local/bin/t3" service install
    '';
  };
in
{
  options.mymod.home.t3Code = {
    enable = lib.mkEnableOption "the T3 Code server as a background service";

    channel = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "nightly"
      ];
      default = "nightly";
      description = "Release channel for the first install. After that, `t3 update` decides.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Runs once, while the t3 command is missing.
    systemd.user.services.t3code-install = {
      Unit = {
        Description = "Install the T3 Code headless server";
        ConditionPathExists = "!%h/.local/bin/t3";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${t3CodeInstall}/bin/t3code-install";
        # The network may not be up yet at boot.
        Restart = "on-failure";
        RestartSec = 60;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
