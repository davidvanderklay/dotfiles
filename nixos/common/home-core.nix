{ config, pkgs, ... }:

{
  imports = [
    ./nixvim.nix
  ];

  home.packages =
    with pkgs;
    [
      # Programming tools
      gcc # C/C++ Compiler
      python3
      gnumake # Make
      clang-tools # Clangd, clang-format
      rustc # Rust Compiler
      cargo # Rust Package Manager
      nodejs_22 # Node/NPM

      awscli2
      btop
      unzip
      unrar
      texlive.combined.scheme-full
      texlab
      wget
      croc
      zstd
      tailscale
      syncthing
      gnupg
      jq
      qrencode

      # Formatters
      rustfmt

      fastfetch
      tmux
      yazi
      fzf
      ripgrep
      fd
      quarto
      (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./scripts/tmux-sessionizer))
      # pkgs.wl-clipboard
    ]
    ++ (lib.optionals stdenv.isLinux [ pkgs.wl-clipboard ]);

  # xdg.configFile."nvim".source = ./nvim;

  programs.git = {
    enable = true;
    # "settings" replaces userName, userEmail, and extraConfig
    settings = {
      user = {
        name = "davidvanderklay";
        email = "davidvanderklay@gmail.com";
      };
      # Any other config goes here, e.g.:
      # init.defaultBranch = "main";
      # core.editor = "nvim";
    };
  };

  programs.direnv = {
    enable = true;

    # "nix-direnv" is the special sauce that makes it fast and keeps
    # your garbage collector from deleting your dev environments.
    nix-direnv.enable = true;

    # Optional: silence the "direnv: loading..." verbose messages
    # config = {
    #   global = {
    #     warn_timeout = "0s";
    #   };
    # };
  };

  # 2. STARSHIP CONFIGURATION
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      aws = {
        disabled = true;
      };
    };
    # Link your custom toml if it exists, otherwise comment this line out
    # settings = pkgs.lib.importTOML ./starship.toml;
  };

  # 4. FZF CONFIGURATION
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden";
    fileWidgetCommand = "rg --files --hidden";
  };

  programs.lazygit = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
