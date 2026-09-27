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
  };

  services.xremap.enable = false;

  # Keep Wine independent of the gaming profile.
  home.packages = with pkgs; [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    wineWow64Packages.stable
    winetricks
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
    };
  };
}
