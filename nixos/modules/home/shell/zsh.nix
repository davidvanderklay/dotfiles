{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true; # Native support!

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
    '';
  };
}
