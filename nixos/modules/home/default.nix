{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./core.nix
    ./desktop.nix
    ./t3code.nix
    ./nixvim
    ./ghostty.nix
    ./gaming.nix
    ./niri.nix
    ./hyprland.nix
  ];
}
