{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.nixos.t3Code;
in
{
  options.mymod.nixos.t3Code = {
    enable = lib.mkEnableOption "system libraries for the T3 Code server's downloaded tools";
  };

  config = lib.mkIf cfg.enable {
    # The server downloads chrome-headless-shell to ~/.t3/tools for previews and
    # html_render. It is a generic Linux binary, so nix-ld supplies the loader
    # and the libraries `t3 browser setup` would install on other distros.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-core
        dbus
        expat
        glib
        libgbm
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        nspr
        nss
        systemdLibs
      ];
    };
  };
}
