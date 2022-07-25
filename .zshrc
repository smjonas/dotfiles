export PATH=$PATH:/home/jonas/.local/share/neovim/bin

export SHELL=/usr/bin/zsh
source ~/.aliases

# Set neovim as manpager
export MANPAGER='nvim --appimage-extract-and-run -c "set ft=man"'

# nnn config
export EDITOR=nvim
# x: copy file path after selecting entry with space
export NNN_OPTS=x
export NNN_TRASH=1

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

HISTSIZE=100000000
SAVEHIST=$HISTSIZE
HISTFILE=~/.local/zsh_history

source ~/.local/antigen/antigen.zsh

antigen bundle 'zsh-users/zsh-syntax-highlighting'
antigen bundle 'zsh-users/zsh-autosuggestions'
antigen apply

bindkey '^f' autosuggest-accept
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'
