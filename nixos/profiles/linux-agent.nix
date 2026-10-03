{ inputs, pkgs, ... }:

let
  t3CodeCli = pkgs.callPackage ../packages/t3-code-cli { };
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
    t3CodeCli
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    wineWow64Packages.stable
    winetricks
  ];

  # Restart changed user services when the morning system update activates this profile.
  systemd.user.startServices = true;

  # Lingering on the host starts the headless server before login.
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code headless server";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${t3CodeCli}/bin/t3 serve";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "PATH=/home/geolan/.local/bin:/etc/profiles/per-user/geolan/bin:/run/current-system/sw/bin"
      ];
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
