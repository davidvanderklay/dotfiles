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

  # 3. ZSH CONFIGURATION
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell Aliases
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      g = "git";
      ga = "git add";
      gc = "git commit -m";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
    };

    # InitExtra: This is where we put your custom functions and raw shell code
    initContent = ''
      # --- Keybindings (History Search) ---
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

      # Bind the Up/Down arrow keys to the substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Bindings for Tmux or other terminal modes that send different codes
      bindkey '^[OA' history-substring-search-up
      bindkey '^[OB' history-substring-search-down

      # --- TMUX & SUDO ---
      # Ensure tmux-sessionizer is in your PATH or change this to full path
      bindkey -s ^f "tmux-sessionizer\n"

      sudo-command-line() {
          [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
          if [[ $BUFFER == sudo\ * ]]; then LBUFFER="''${LBUFFER#sudo }"; else LBUFFER="sudo $LBUFFER"; fi
      }
      zle -N sudo-command-line
      bindkey "\e\e" sudo-command-line

      # --- Custom Path Additions ---
      export PATH="$PATH:$HOME/.local/scripts/"
      export PATH="$PATH:$HOME/XyceInstall/Serial/bin/"
    '';
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

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;

    # Replaces: set -g prefix C-a / unbind C-b
    shortcut = "a";

    # Replaces: set -g base-index 1
    baseIndex = 1;

    # Replaces: set -sg escape-time 0
    escapeTime = 0;

    # Replaces: set -g mouse on
    mouse = true;

    plugins = with pkgs; [
      tmuxPlugins.yank

      # --- KANAGAWA THEME (Custom Build) ---
      {
        plugin = tmuxPlugins.mkTmuxPlugin {
          pluginName = "kanagawa";
          version = "master";
          src = pkgs.fetchFromGitHub {
            owner = "Nybkox";
            repo = "tmux-kanagawa";
            rev = "master";
            # DELETE THIS LINE AND PASTE THE REAL HASH AFTER FIRST BUILD FAIL:
            sha256 = "sha256-ldc++p2PcYdzoOLrd4PGSrueAGNWncdbc5k6wmFM9kQ=";

          };
        };
        extraConfig = ''
          set -g @kanagawa-theme 'dragon'
          set -g @kanagawa-ignore-window-colors true
        '';
      }
    ];

    extraConfig = ''
      set -g allow-passthrough on # ADD THIS LINE
      set -g status-position top
      setw -g pane-base-index 1

      # Vim-like Pane Navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Sessionizer 
      # Note: We use the command name directly because Nix installed it to your PATH
      bind-key -r f run-shell "tmux neww tmux-sessionizer"
    '';
  };

  home.stateVersion = "25.11";
}
