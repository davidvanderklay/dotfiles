{ config, pkgs, lib, ... }:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core.enable = true;
    nixvim.enable = true;
    desktop.enable = true;
    niri.enable = true;
    ghostty.enable = true;
    gaming.enable = true;
  };
}
