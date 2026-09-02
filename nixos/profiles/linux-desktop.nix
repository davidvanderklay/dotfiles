{ ... }:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core.enable = true;
    nixvim.enable = true;
    workstation.enable = true;
    ghostty.enable = true;
    gaming.enable = true;
  };
}
