# The following lines were added by compinstall
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/florian.laporte/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# ----- Histfile
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

# ----- zsh options
setopt HIST_SAVE_NO_DUPS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ----- Vi / Helix
# Surprisingly enough, I don't use Vi mode. I find it clunky at best, and while
# plugins like zsh-vi-mode fix a lot, some things remain (like an annoying mode-switch delay,
# even with a tweaked KEYTIMEOUT).
# Instead, I rely on ^E to *E*dit the current command in Helix.
export EDITOR="hx"
export VISUAL="hx"
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -e
bindkey '^E' edit-command-line

# ----- Keybinds
# I'd make a custom keymap, but unfortunately many plugins will boldy
# assume your keymap is one of 'emacs', 'viins', or 'vicmd'.
bindkey '^[[3~' delete-char  # Del
#bindkey '^R'  # <- this is set by the fzf source down below
bindkey '^H' backward-kill-word  # CTRL backspace
bindkey '^[[3;5~' kill-word  # CTRL delete
bindkey "^[[1;5D" backward-word  # CTRL left arrow
bindkey "^[[1;5C" forward-word  # CTRL right arrow
bindkey '^[[H' beginning-of-line  # Home
bindkey '^[[F' end-of-line  # End
bindkey '^U' undo  # CTRL U

# Brew env vars
# Instead of: eval "$(brew shellenv)", because that command takes ~30ms...
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
# export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"  I already do this below
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/opt/info:${INFOPATH:-}"

# ----- PATH
path+=("${HOME}/bin")
path+=("/opt/homebrew/opt/postgresql@17/bin")
path+=("${HOME}/.local/bin")
path+=("/opt/homebrew/bin")
path+=("/opt/homebrew/sbin")
export PATH

# ----- Plugins
fpath=(/opt/homebrew/share/zsh-completions $fpath)
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ----- Prompt
#fpath=(~/dotfiles/zsh/zsh_fpath $fpath)
#autoload -Uz zsh_prompt; zsh_prompt

# ----- fzf completions & keybinds
source <(fzf --zsh)

# ----- Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gl='git log'
alias gf='git fetch'
alias gp='git pull'
alias ls='eza -a'
alias ll='eza -al'
alias helix='hx'
alias img='img2sixel'
alias py='ipython'
alias translate='cd src/i18n && qargo-translate translate && git add . && git commit -m "Add translations using qargo-translate."'

# ----- Functions
# Install packages using yay
function yayin() {
    yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}'| xargs -ro yay -S
}
# Remove installed packages using yay
function yayre() {
    yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns
}
# yazi alias + exist at yazi's directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# Git diffs in Helix
hxdiff() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not in a git repo"
    return 1
  fi
  local root=$(git rev-parse --show-toplevel)
  local -a files=("${(@f)$(git diff --name-only "$@")}")
  files=(${files:#})  # remove empty entries
  if (( $#files )); then
    hx "${files[@]/#/$root/}"
  else
    echo "Nothing to diff"
  fi
}
# Same as above, but relative (so only diff at or below cwd)
hxrdiff() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not in a git repo"
    return 1
  fi
  local -a files=("${(@f)$(git diff --relative --name-only "$@")}")
  files=(${files:#})  # remove empty entries
  if (( $#files )); then
    hx "$files[@]"
  else
    echo "Nothing to diff"
  fi
}

# Directory history command 'd'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# Prompt
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Pyenv
# The following replaces `eval "$(pyenv init -)"`, because that shit's slow. I'll simply hardcode the return value here.
path=("${(@)path:#$HOME/.pyenv/shims}") # Remove existing pyenv shims from PATH (zsh-native, no subprocess)

export PATH="$HOME/.pyenv/shims:$PATH"
export PYENV_SHELL=zsh
source '/opt/homebrew/Cellar/pyenv/2.6.25/completions/pyenv.zsh'
# command pyenv rehash
# The above is tremendously slow, I'll just manually rehash shims when something requires it
pyenv() {
  local command=${1:-}
  [ "$#" -gt 0 ] && shift
  case "$command" in
  rehash|shell)
    eval "$(pyenv "sh-$command" "$@")"
    ;;
  *)
    command pyenv "$command" "$@"
    ;;
  esac
}

# Node Version Manager
# mkdir -p "${HOME}/.nvm"
# NVM_DIR="${HOME}/.nvm"
# source /opt/homebrew/opt/nvm/nvm.sh
# I omitted the above to use fnm instead of nvm, for the simple reason that the latter is unbearably slow.
eval "$(fnm env --use-on-cd --shell zsh)"

# Google Cloud (`google-cloud-sdk`)
# The HOMEBREW_PREFIX variable comes from the `brew shellenv` command executed & sourced earlier
source "${HOMEBREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc"
source "${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc"
export USE_GKE_CLOUD_AUTH_PLUGIN=True


# Qargo docs state they want this ~/.docker/cli-plugins/docker-compose file, but I don't know why...
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose

# Function to find & run VSCode tasks/launches interactively with fzf
vt() {
  vsctasks list --root "${1:-.}" \
    | fzf --preview 'vsctasks info {}' --preview-window=right:40% \
    | vsctasks run --root "${1:-.}"
}

# Emit OSC-7 escape sequences
function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function chpwd-osc7-pwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}
add-zsh-hook -Uz chpwd chpwd-osc7-pwd
