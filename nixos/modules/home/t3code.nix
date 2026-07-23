{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.home.t3code;
  system = pkgs.stdenv.hostPlatform.system;
  codex = inputs.codex-cli-nix.packages."${system}".default;

  t3Server = pkgs.writeShellApplication {
    name = "t3-code-server-nightly";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      findutils
      gawk
      gnugrep
      gnutar
      gzip
      git
      lsof
      nodejs_22
      openssh
      tailscale
      codex
    ];
    text = ''
      exec npx --yes t3@nightly serve \
        --base-dir "$HOME/.t3" \
        --tailscale-serve
    '';
  };
in
{
  options.mymod.home.t3code = {
    enable = lib.mkEnableOption "headless T3 Code nightly server";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    systemd.user.services.t3-code-server = {
      Unit = {
        Description = "T3 Code nightly server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${t3Server}/bin/t3-code-server-nightly";
        Environment = [
          "HOME=%h"
          "NPM_CONFIG_CACHE=%h/.cache/npm"
        ];
        Restart = "on-failure";
        RestartSec = "10s";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
