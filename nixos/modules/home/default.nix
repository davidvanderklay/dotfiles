{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./core.nix
    ./desktop.nix
    ./nixvim
    ./ghostty.nix
    ./gaming.nix
    ./niri.nix
    ./hyprland.nix
  ];
}
