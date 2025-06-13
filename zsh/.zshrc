
# The following lines were added by compinstall
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/flo/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# Basics & zsh options
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
bindkey -v  # vi mode
export KEYTIMEOUT=1  # mode switches are super slow without this
bindkey ^R history-incremental-search-backward
setopt HIST_SAVE_NO_DUPS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Vim
export EDITOR="nvim"
export VISUAL="nvim"
# These three allow you to edit your commands in your favorite editor, by pressing 'v' in normale mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Keybinds
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

# PATH
path+=("${HOME}/dotfiles/bin")
export PATH

# Plugins
fpath=(path/to/zsh-completions/src $fpath)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Prompt
fpath=(~/dotfiles/zsh/zsh_fpath $fpath)
autoload -Uz zsh_prompt; zsh_prompt

# fzf
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gl='git log'
alias gf='git fetch'
alias gp='git pull'
alias ls='eza -a'
alias ll='eza -al'

# Functions
# Install packages using yay
function yayin() {
    yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}'| xargs -ro yay -S
}
# Remove installed packages using yay
function yayre() {
    yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns
}

# Directory history command 'd'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

