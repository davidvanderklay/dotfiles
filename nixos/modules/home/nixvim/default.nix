{ lib, ... }:
{
  options.mymod.home.nixvim = {
    enable = lib.mkEnableOption "nixvim configuration";
  };

  imports = [
    ./config.nix
    ./plugins.nix
    ./keymaps.nix
  ];
}
