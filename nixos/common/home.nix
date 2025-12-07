{ config, pkgs, ... }:

{
  imports = [
    ./gnome.nix  # <--- Add this line near the top
  ];

	home.username = "geolan";
	home.homeDirectory = "/home/geolan";
  
  home.packages = with pkgs; [
    awscli2
    btop
    unzip
    unrar
    distrobox
    texlive.combined.scheme-full
    texlab

    # Gaming
    lutris
    heroic
    r2modman
    prismlauncher
    protonplus
    ludusavi

    # Social
    bitwarden-desktop
    vesktop

    # Wine stuff
    wineWow64Packages.stable
    winetricks

    ungoogled-chromium


    tmux
    yazi
    fzf
    (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./scripts/tmux-sessionizer))
  ];

	xdg.configFile."nvim".source = ./nvim;

	programs.git = {
		enable = true;
		userName = "davidvanderklay";
		userEmail = "davidvanderklay@gmail.com"	;
	};

 # 1. GHOSTTY CONFIGURATION
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # We link your config file from the dotfiles directory
    installBatSyntax = false; # Fixes a common conflict issue
  };
  
  # Link the config file manually to ensure it uses your specific file
  xdg.configFile."ghostty/config".source = ./ghostty/config;

  # 2. STARSHIP CONFIGURATION
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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
    initExtra = ''
      # --- Keybindings (History Search) ---
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward

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
            sha256 = "sha256-BcPErvbG7QwhxXgc3brSQKw3xd3jO5MHNxUj595L0uk=";
          };
        };
        extraConfig = ''
          set -g @kanagawa-theme 'dragon'
          set -g @kanagawa-ignore-window-colors true
        '';
      }
    ];

    extraConfig = ''
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

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
		withNodeJs = true;
		withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];

		extraPackages = with pkgs; [
			gcc
			gnumake
			unzip
      tree-sitter
			
			# Search tools
			ripgrep
			fd

			# LSPS, formatters
			lua-language-server
			nil
			nixpkgs-fmt
			pyright
			gopls
			rust-analyzer
			clang-tools
			nodePackages.typescript-language-server
			nodePackages.prettier
		];
	};

	home.stateVersion = "25.11";
}
