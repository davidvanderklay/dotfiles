{ inputs, ... }:

{
  imports = [
    ../modules/home
    inputs.xremap.homeManagerModules.default
  ];

  mymod.home = {
    core.enable = true;
    nixvim.enable = true;
    workstation.enable = true;
    ghostty.enable = true;
    gaming.enable = true;
  };
}
