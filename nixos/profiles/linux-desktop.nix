{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core.enable = true;
    nixvim.enable = true;
    desktop.enable = true;
    ghostty.enable = true;
    gaming.enable = true;
  };
}
