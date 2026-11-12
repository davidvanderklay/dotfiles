{ inputs, pkgs, ... }:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core = {
      enable = true;
      includePersonalTools = false;
    };
    nixvim.enable = true;
    ghostty.enable = true;
    # Lingering on the host keeps the T3 Code server running before login.
    t3Code.enable = true;
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
    };
  };
}
