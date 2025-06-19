# The following lines were added by compinstall
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/flo/.zshrc'

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

# ----- Vi
# Surprisingly enough, I don't use Vi mode. I find it clunky at best, and while
# plugins like zsh-vi-mode fix a lot, some things remain (like an annoying mode-switch delay).
# Instead, I rely on ^V to edit the current command in nvim.
export EDITOR="nvim"
export VISUAL="nvim"
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -e
bindkey '^V' edit-command-line

# ----- Keybinds
# I'd make a custom keymap, but unfortunately many plugins will boldy
# assume your keymap is one of 'emacs', 'viins', or 'vicmd'.
bindkey '^[[3~' delete-char  # Del
#bindkey '^R'  # <- this is set by the fzf source down below
bindkey '^H' backward-kill-word  # CTRL backspace
bindkey '5~' kill-word  # CTRL delete
bindkey "^[[1;5D" backward-word  # CTRL left arrow
bindkey "^[[1;5C" forward-word  # CTRL right arrow
bindkey '^[[H' beginning-of-line  # Home
bindkey '^[[F' end-of-line  # End
bindkey '^U' undo  # CTRL U

# ----- PATH
path+=("${HOME}/dotfiles/bin")
export PATH

# ----- Plugins
fpath=(path/to/zsh-completions/src $fpath)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ----- Prompt
#fpath=(~/dotfiles/zsh/zsh_fpath $fpath)
#autoload -Uz zsh_prompt; zsh_prompt

# ----- fzf
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# ----- Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gl='git log'
alias gf='git fetch'
alias gp='git pull'
alias ls='eza -a'
alias ll='eza -al'
alias img='img2sixel'

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

# ----- Directory history command 'd'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# Prompt
eval "$(starship init zsh)"

