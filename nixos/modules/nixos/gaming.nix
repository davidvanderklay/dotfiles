{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.mySystem.gaming;
in
{
  options.mySystem.gaming.enable = lib.mkEnableOption "System-level gaming components";

  config = lib.mkIf cfg.enable {
    # 1. Steam & Essentials
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    # 2. Anime Game Launcher (from your flake inputs)
    # We can include this logic here so it's all in one place
    # programs.aagl.enable = true; # (Adjust based on AAGL's specific options)

    # 3. System-wide gaming packages (stuff that needs drivers/wrappers)
    environment.systemPackages = with pkgs; [
      mangohud # FPS counter
      vulkan-tools
    ];

    # Ensure 32-bit support for Steam (usually handled by programs.steam, but good to be safe)
    hardware.graphics.enable32Bit = true;
  };
}
