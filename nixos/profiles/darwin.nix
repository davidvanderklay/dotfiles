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

  xdg.configFile."skhd/skhdrc".text = ''
    alt - w : open -na "Zen"
    alt - u : open -na "Ghostty"
    alt - r : open -a "Finder" ~
    alt - q : skhd -k "cmd - w"
    alt + shift - q : skhd -k "cmd - q"
    alt - space : open -a "Mission Control"
  '';
}
