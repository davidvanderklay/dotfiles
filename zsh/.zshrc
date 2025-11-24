# =============================================================================
# 1. OS DETECTION & PATH SETUP
# =============================================================================

# Detect OS
[[ "$(uname -s)" == "Darwin" ]] && IS_MACOS=1 || IS_MACOS=0

# Add Homebrew to PATH (Apple Silicon & Intel)
if [[ $IS_MACOS -eq 1 ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
    eval "$(/usr/local/bin/brew shellenv 2>/dev/null)"
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
fi

# Standard Paths
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$PATH"
export PATH="$PATH:$HOME/.local/scripts/"
export PATH="$PATH:$HOME/XyceInstall/Serial/bin/"

# Haskell (GHCup) - check if file exists to avoid errors
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# =============================================================================
# 2. PLUGIN MANAGER (Self-Bootstrapping & Portable)
# =============================================================================

# We use this INSTEAD of sourcing /opt/homebrew/share/...
# This ensures plugins work identically on Linux and Mac.
ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$ZPLUGINDIR"

function zsh_add_plugin() {
    local repo="$1"
    local plugin_name="${repo:t}"
    local plugin_dir="$ZPLUGINDIR/$plugin_name"

    if [[ ! -d "$plugin_dir" ]]; then
        echo "Installing $plugin_name..."
        git clone --depth 1 "https://github.com/$repo.git" "$plugin_dir"
    fi

    if [[ -f "$plugin_dir/$plugin_name.plugin.zsh" ]]; then
        source "$plugin_dir/$plugin_name.plugin.zsh"
    elif [[ -f "$plugin_dir/$plugin_name.zsh" ]]; then
        source "$plugin_dir/$plugin_name.zsh"
    fi
}

# =============================================================================
# 3. BASIC SETTINGS
# =============================================================================

autoload -U colors && colors

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Editor
export EDITOR=nvim

# =============================================================================
# 4. AUTOCOMPLETION & KEYBINDINGS
# =============================================================================

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zmodload zsh/complist
_comp_options+=(globdots)

# Cache completion for speed
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# --- HISTORY SEARCH (Up Arrow) ---
zmodload zsh/terminfo
bindkey "${terminfo[kcuu1]}" history-search-backward
bindkey "${terminfo[kcud1]}" history-search-forward
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# --- TMUX & SUDO ---
bindkey -s ^f "tmux-sessionizer\n"

sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    if [[ $BUFFER == sudo\ * ]]; then LBUFFER="${LBUFFER#sudo }"; else LBUFFER="sudo $LBUFFER"; fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

# =============================================================================
# 5. ENVIRONMENT SPECIFIC CONFIGS (Conda & Projects)
# =============================================================================

# Conda (Mac Specific Path vs Generic)
if [[ $IS_MACOS -eq 1 ]]; then
    CONDA_PATH="/opt/homebrew/Caskroom/miniconda/base/bin/conda"
else
    # Adjust this if your Linux conda path is different
    CONDA_PATH="$HOME/miniconda3/bin/conda"
fi

# Only run conda init if the binary exists
if [ -f "$CONDA_PATH" ]; then
    __conda_setup="$('$CONDA_PATH' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        export PATH="$(dirname "$CONDA_PATH"):$PATH"
    fi
    unset __conda_setup
fi

# CSCE441 Project Paths (Switch based on OS)
if [[ $IS_MACOS -eq 1 ]]; then
    export GLM_INCLUDE_DIR="$HOME/Documents/cppDev/CSCE441/glm-1.0.1/"
    export GLFW_DIR="$HOME/Documents/cppDev/CSCE441/glfw-3.4"
    export GLEW_DIR="$HOME/Documents/cppDev/CSCE441/glew-2.1.0"
    export TERM="ghostty"
else
    export ANDROID_HOME="/home/geolan/Android/Sdk/"
    export GLM_INCLUDE_DIR="/home/geolan/Projects/CSCE441/glm-1.0.1"
    export GLFW_DIR="/home/geolan/Projects/CSCE441/glfw-3.4"
    export GLEW_DIR="/home/geolan/Projects/CSCE441/glew-2.1.0"
fi

# =============================================================================
# 6. LOAD PLUGINS
# =============================================================================

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"

# FZF (Check various install locations)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi
source <(fzf --zsh 2>/dev/null)

export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# =============================================================================
# 7. PROMPT (Starship)
# =============================================================================

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    # Fallback prompt if Starship isn't installed
    PROMPT='%F{green}%n%f@%F{magenta}%m%f:%F{blue}%~%f$ '
fi

# =============================================================================
# 8. ALIASES
# =============================================================================

# OS-Dependent `ls` alias
if [[ $IS_MACOS -eq 1 ]]; then
    alias ls='ls -G' # BSD ls color
else
    alias ls='ls --color=auto' # GNU ls color
fi

alias grep='grep --color=auto'
alias sudo="sudo "
alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# Yazi Wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
