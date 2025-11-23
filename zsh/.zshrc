# =============================================================================
# 1. BASIC SETTINGS
# =============================================================================

# Enable colors
autoload -U colors && colors

# History settings (OMZ usually hides this)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.

# Editor
export EDITOR=nvim

# =============================================================================
# 2. AUTOCOMPLETION (The native way, no OMZ needed)
# =============================================================================

autoload -Uz compinit
zstyle ':completion:*' menu select              # Interactive selection menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colorize completion
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# Initialize completion system (caching for speed)
zmodload zsh/complist
_comp_options+=(globdots) # Include hidden files in completion
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# =============================================================================
# 3. PLUGINS
# =============================================================================

# Source local plugins if they exist
if [ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# FZF Integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh 2>/dev/null) # 2>/dev/null in case fzf isn't installed on a new system

# =============================================================================
# 4. PROMPT (Starship or Fallback)
# =============================================================================

# If starship is installed, use it. If not, use a simple fallback prompt.
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    # A simple, colorful prompt as a backup for systems without starship
    PROMPT='%F{green}%n@%m%f %F{blue}%~%f $ '
fi

# =============================================================================
# 5. ALIASES & FUNCTIONS
# =============================================================================

# Common aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sudo="sudo " # Allows aliases to be sudo'ed

# Git aliases (Replacing OMZ git plugin)
alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# Yazi wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Double-tap ESC to toggle sudo (Replaces OMZ sudo plugin)
sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

# =============================================================================
# 6. USER CONFIG & EXPORTS
# =============================================================================

# Path setup
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
export PATH="$PATH:$HOME/.local/scripts/"
export PATH="$PATH:$HOME/XyceInstall/Serial/bin/"

# Language/SDK Exports
[ -f "/home/geolan/.ghcup/env" ] && . "/home/geolan/.ghcup/env" # ghcup-env
# . /opt/asdf-vm/asdf.sh

export ANDROID_HOME=/home/geolan/Android/Sdk/
export GLM_INCLUDE_DIR=/home/geolan/Projects/CSCE441/glm-1.0.1
export GLFW_DIR=/home/geolan/Projects/CSCE441/glfw-3.4
export GLEW_DIR=/home/geolan/Projects/CSCE441/glew-2.1.0

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Keybindings
bindkey -s ^f "tmux-sessionizer\n"
