{ inputs, ... }:

{
  imports = [
    ./core.nix
    ./agent-config.nix
    ./workstation.nix
    ./nixvim
    ./ghostty.nix
    ./gaming.nix
    ./niri.nix
    ./hyprland.nix
  ];
}
