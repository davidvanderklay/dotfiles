{ inputs, ... }:

{
  imports = [
    ./core.nix
    ./agent-config.nix
    ./desktop.nix
    ./nixvim
    ./ghostty.nix
    ./gaming.nix
    ./niri.nix
    ./hyprland.nix
  ];
}
