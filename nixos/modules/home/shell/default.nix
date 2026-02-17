{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHome.shell;
in
{
  options.myHome.shell = {
    enable = lib.mkEnableOption "My custom shell environment";
  };

  config = lib.mkIf cfg.enable {
    imports = [
      ./zsh.nix
      ./tmux.nix
      ./starship.nix
      ./git.nix
    ];

    # CLI tools that should always be present with my shell
    home.packages =
      with pkgs;
      [
        fzf
        ripgrep
        fd
        jq
        btop
        yazi
        fastfetch
        (pkgs.writeShellScriptBin "tmux-sessionizer" (
          builtins.readFile ../../../common/scripts/tmux-sessionizer
        ))
      ]
      ++ (lib.optionals stdenv.isLinux [ pkgs.wl-clipboard ]);
  };
}
