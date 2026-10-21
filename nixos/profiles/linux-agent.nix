{ inputs, pkgs, ... }:

let
  # Installs the headless server with upstream's installer on first boot. After
  # that, `t3 service install` owns t3code.service and `t3 update` replaces it.
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
      curl -fsSL https://t3.codes/install.sh | T3CODE_CHANNEL=nightly sh
      "$HOME/.local/bin/t3" service install
    '';
  };
in
{
  imports = [ ../modules/home ];

  mymod.home = {
    core = {
      enable = true;
      includePersonalTools = false;
    };
    nixvim.enable = true;
    ghostty.enable = true;
  };

  services.xremap.enable = false;

  # Keep Wine independent of the gaming profile.
  home.packages = with pkgs; [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    wineWow64Packages.stable
    winetricks
  ];

  # Restart changed user services when the morning system update activates this profile.
  systemd.user.startServices = true;

  # Lingering on the host keeps the server running before login.
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
    };
  };
}
