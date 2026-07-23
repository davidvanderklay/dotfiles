{ ... }:

{
  imports = [ ../modules/home ];

  mymod.home = {
    core = {
      enable = true;
      homeDirectory = "/Users/geolan";
    };
    t3code.enable = true;
    nixvim.enable = true;
  };
}
