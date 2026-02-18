{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.mymod.home.core;
  configsPath = ../../configs;
in
{
  options.mymod.home.core = {
    enable = lib.mkEnableOption "core home-manager configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "geolan";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/geolan";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = cfg.userName;
      homeDirectory = cfg.homeDirectory;
      stateVersion = "25.11";

      packages =
        with pkgs;
        [
          gcc
          python3
          gnumake
          clang-tools
          rustc
          cargo
          nodejs_22
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
          rustfmt
          fastfetch
          tmux
          yazi
          fzf
          ripgrep
          fd
          quarto
          (pkgs.writeShellScriptBin "tmux-sessionizer" (
            builtins.readFile "${configsPath}/scripts/tmux-sessionizer"
          ))
        ]
        ++ lib.optionals stdenv.isLinux [ wl-clipboard ];
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "davidvanderklay";
          email = "davidvanderklay@gmail.com";
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings.aws.disabled = true;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

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

      initContent = ''
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey '^[OA' history-substring-search-up
        bindkey '^[OB' history-substring-search-down
        bindkey -s ^f "tmux-sessionizer\n"

        sudo-command-line() {
            [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
            if [[ $BUFFER == sudo\ * ]]; then LBUFFER="''${LBUFFER#sudo }"; else LBUFFER="sudo $LBUFFER"; fi
        }
        zle -N sudo-command-line
        bindkey "\e\e" sudo-command-line

        export PATH="$PATH:$HOME/.local/scripts/"
        export PATH="$PATH:$HOME/XyceInstall/Serial/bin/"
      '';
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      fileWidgetCommand = "rg --files --hidden";
    };

    programs.lazygit.enable = true;

    programs.opencode.enable = true;

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 100000;
      shortcut = "a";
      baseIndex = 1;
      escapeTime = 0;
      mouse = true;

      plugins = with pkgs; [
        tmuxPlugins.yank
        {
          plugin = tmuxPlugins.mkTmuxPlugin {
            pluginName = "kanagawa";
            version = "master";
            src = pkgs.fetchFromGitHub {
              owner = "Nybkox";
              repo = "tmux-kanagawa";
              rev = "master";
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
        set -g allow-passthrough on
        set -s set-clipboard on
        set -g status-position top
        setw -g pane-base-index 1
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R
        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    };
  };
}
