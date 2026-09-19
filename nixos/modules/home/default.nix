{ inputs, ... }:

{
  imports = [
    ./core.nix
    ./agent-config.nix
    ./workstation.nix
    inputs.xremap.homeManagerModules.default
    ./nixvim
    ./ghostty.nix
    ./gaming.nix
    ./niri.nix
    ./hyprland.nix
  ];
}
