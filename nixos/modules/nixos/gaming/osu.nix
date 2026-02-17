{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.mySystem.gaming.osu.enable = lib.mkEnableOption "osu! stable (nix-gaming)";

  config = lib.mkIf config.mySystem.gaming.osu.enable {
    environment.systemPackages = [
      inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
    ];
  };
}
