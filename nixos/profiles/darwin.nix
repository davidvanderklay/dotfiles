{ ... }:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core = {
      enable = true;
      homeDirectory = "/Users/geolan";
    };
    nixvim.enable = true;
  };
}
