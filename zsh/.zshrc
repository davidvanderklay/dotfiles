# =============================================================================
# 1. PLUGIN MANAGER (Self-Bootstrapping)
# =============================================================================

# Directory to store plugins
ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$ZPLUGINDIR"

# Function to auto-download and load plugins
function zsh_add_plugin() {
    local repo="$1"
    local plugin_name="${repo:t}"
    local plugin_dir="$ZPLUGINDIR/$plugin_name"

    # 1. Install if missing
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Installing $plugin_name..."
        git clone --depth 1 "https://github.com/$repo.git" "$plugin_dir"
    fi

    # 2. Source the plugin file (tries standard naming conventions)
    if [[ -f "$plugin_dir/$plugin_name.plugin.zsh" ]]; then
        source "$plugin_dir/$plugin_name.plugin.zsh"
    elif [[ -f "$plugin_dir/$plugin_name.zsh" ]]; then
        source "$plugin_dir/$plugin_name.zsh"
    else
        echo "Error: Could not find entry point for $plugin_name"
    fi
}

# =============================================================================
# 2. BASIC SETTINGS
# =============================================================================

# Enable colors
autoload -U colors && colors

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE

# Editor
export EDITOR=nvim

# =============================================================================
# 3. AUTOCOMPLETION & KEYBINDINGS
# =============================================================================

# Initialize completion
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

zmodload zsh/complist
_comp_options+=(globdots)

# Faster startup: check for dump file
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# --- HISTORY SEARCH (The Up Arrow Feature) ---
zmodload zsh/terminfo
bindkey "${terminfo[kcuu1]}" history-search-backward
bindkey "${terminfo[kcud1]}" history-search-forward
# Fallback for systems without terminfo
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# --- FZF Support ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh 2>/dev/null)

# =============================================================================
# 4. LOAD PLUGINS
# =============================================================================

# Simply list the "user/repo" you want here. 
# It will git clone them if they are missing.

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
# zsh_add_plugin "zsh-users/zsh-history-substring-search" # Optional if you want fuzzy search

# =============================================================================
# 5. PROMPT
# =============================================================================

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT='%F{green}%n@%m%f %F{blue}%~%f $ '
fi

# =============================================================================
# 6. ALIASES & FUNCTIONS
# =============================================================================

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sudo="sudo "

# Git
alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Toggle Sudo with Esc-Esc
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

bindkey -s ^f "tmux-sessionizer\n"

# =============================================================================
# 7. EXPORTS
# =============================================================================

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
export PATH="$PATH:$HOME/.local/scripts/"
export PATH="$PATH:$HOME/XyceInstall/Serial/bin/"

[ -f "/home/geolan/.ghcup/env" ] && . "/home/geolan/.ghcup/env"

export ANDROID_HOME=/home/geolan/Android/Sdk/
export GLM_INCLUDE_DIR=/home/geolan/Projects/CSCE441/glm-1.0.1
export GLFW_DIR=/home/geolan/Projects/CSCE441/glfw-3.4
export GLEW_DIR=/home/geolan/Projects/CSCE441/glew-2.1.0
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
