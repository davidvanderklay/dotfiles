{ config, pkgs, ... }:

{
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
      set -s set-clipboard on     # ADD THIS LINE
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
}
