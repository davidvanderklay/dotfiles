{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.mySystem.gaming.aagl.enable = lib.mkEnableOption "Anime Game Launcher (Genshin/HSR)";

  config = lib.mkIf config.mySystem.gaming.aagl.enable {
    # Pull in the cache settings from the input
    nix.settings = inputs.aagl.nixConfig;

    # Enable the specific launcher you use
    programs.honkers-railway-launcher.enable = true;
    # programs.anime-game-launcher.enable = true; # (Add if you want Genshin too)
  };
}
