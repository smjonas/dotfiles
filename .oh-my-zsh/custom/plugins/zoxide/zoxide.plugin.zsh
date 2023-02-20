if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
else
  echo '[oh-my-zsh] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi
