{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mymod.nixos.android;
in
{
  options.mymod.nixos.android = {
    enable = lib.mkEnableOption "Android Studio and a runnable Android SDK";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.android_sdk.accept_license = true;
    environment.systemPackages = [ pkgs.android-studio ];

    # Android Studio downloads generic Linux SDK binaries to ~/Android/Sdk.
    # They run inside Studio's FHS sandbox, but tools that call them directly
    # (T3 Code's device list runs `emulator -list-avds`) exit 127 without a
    # real dynamic loader. These are the system libraries adb, the emulator and
    # its bundled Qt need beyond what the SDK ships.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        libpng
        expat
        dbus
        libuuid
        libbsd
        nss
        nspr
        libpulseaudio
        libglvnd
        libdrm
        libgbm
        libx11
        libxcb
        libxext
        libxi
        libsm
        libice
        libxkbfile
      ];
    };
  };
}
