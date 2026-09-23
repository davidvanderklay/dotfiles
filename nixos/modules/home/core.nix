{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.mymod.home.core;
  configsPath = ../../configs;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  ticktickLockfile = ../../packages/ticktick-cli/package-lock.json;

  ticktickCli = pkgs.buildNpmPackage {
    pname = "ticktick-cli";
    version = "0.1.13";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@ticktick/ticktick-cli/-/ticktick-cli-0.1.13.tgz";
      hash = "sha256-oqkXbAyQaeAMuU+0WC3Hp/YiP8AHW8itZIN3PvVuvg8=";
    };

    sourceRoot = "package";
    nodejs = pkgs.nodejs_22;
    npmDepsHash = "sha256-yDPYMcncKOG8pu+5hNnf8mAvjv3gBU5d+VFD2sXYwSo=";
    dontNpmBuild = true;
    nativeBuildInputs = [ pkgs.jq pkgs.makeWrapper ];

    postPatch = ''
      ${pkgs.jq}/bin/jq 'del(.devDependencies, .scripts)' package.json > package.json.new
      mv package.json.new package.json
      cp ${ticktickLockfile} package-lock.json
    '';

    installPhase = ''
      mkdir -p $out/lib/ticktick-cli
      cp -r dist $out/lib/ticktick-cli/
      install -Dm644 package.json $out/lib/ticktick-cli/package.json
      cp -r node_modules $out/lib/ticktick-cli/
      makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/ticktick \
        --add-flags "$out/lib/ticktick-cli/dist/index.js"
      ln -s ticktick $out/bin/ticktick-cli
    '';

    meta = {
      description = "Command-line interface for TickTick";
      homepage = "https://github.com/TickTeam/ticktick-cli";
      license = lib.licenses.mit;
      mainProgram = "ticktick";
      platforms = lib.platforms.unix;
    };
  };

  opencodeSettings = {
    permission = {
      edit = "ask";
      bash = {
        "*" = "allow";
        "rm *" = "ask";
        "rmdir *" = "ask";
      };
      websearch = "allow";
      codesearch = "allow";
    };
  };

  githubSshSettings = {
    HostName = "ssh.github.com";
    User = "git";
    Port = 443;
    IdentityFile = "~/.ssh/id_ed25519";
    IdentitiesOnly = true;
    AddKeysToAgent = "yes";
    ServerAliveInterval = 30;
    ServerAliveCountMax = 3;
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    # macOS stores SSH passphrases in the login keychain. Together with
    # AddKeysToAgent this keeps the key available to the launchd agent after
    # reboots, so GUI apps such as lazygit and T3 Code can use Git over SSH.
    UseKeychain = "yes";
  };
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
          pnpm
          awscli2
          btop
          unzip
          unrar
          texliveSmall
          texlab
          wget
          croc
          zstd
          tailscale
          syncthing
          rclone
          gnupg
          pinentry-curses
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
          (pkgs.writeShellScriptBin "paseo-init" (builtins.readFile "${configsPath}/scripts/paseo-init"))
        ]
        # macOS provides these CLI tools through Homebrew.
        ++ lib.optionals (!isDarwin) [
          ticktickCli
          inputs.claude-code.packages."${pkgs.stdenv.hostPlatform.system}".default
          inputs.opencode-nix.packages."${pkgs.stdenv.hostPlatform.system}".default
        ]
        # codex-cli-nix has no darwin package in its flake; keep it
        # Linux-only until upstream publishes one.
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          wl-clipboard
          inputs.codex-cli-nix.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "davidvanderklay";
          email = "davidvanderklay@gmail.com";
        };
        core.excludesFile = "${config.xdg.configHome}/git/ignore";
      };
    };

    xdg.configFile."git/ignore".text = ''
      paseo.json
    '';

    xdg.configFile."paseo/paseo.json".source = "${configsPath}/paseo/paseo.json";

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github.com" = githubSshSettings;

        # TODO(review with David): this * block disables multiplexing and
        # several defaults. Left as-is pending SSH hardening discussion.
        "*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          ForwardAgent = false;
          HashKnownHosts = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 0;
          UserKnownHostsFile = "~/.ssh/known_hosts";
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
      enableCompletion = !pkgs.stdenv.hostPlatform.isDarwin;
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
      }
      // lib.optionalAttrs isDarwin {
        ticktick = "tt";
        "ticktick-cli" = "tt";
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

        export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"
      '';
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      fileWidget.command = "rg --files --hidden";
    };

    programs.lazygit.enable = true;

    xdg.configFile."opencode/opencode.json" = {
      text = builtins.toJSON opencodeSettings;
    };

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
            # Pinned by hash, not tag: upstream has no releases.
            # Re-fetch updates the hash; build fails loudly on drift.
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
