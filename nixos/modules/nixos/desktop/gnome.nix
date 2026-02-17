{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop.gnome;
in
{
  options.mySystem.desktop.gnome.enable = lib.mkEnableOption "GNOME Desktop";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Remove bloat usually included with GNOME
    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-tour
        cheese # photo booth
        gedit # text editor
      ]
    );
  };
}
