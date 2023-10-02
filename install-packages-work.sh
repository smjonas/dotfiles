#!/bin/bash
apt install -y build-essential libnewlib-arm-none-eabi
apt install -y zsh kitty fzf ripgrep python3-pip luarocks

# Make zsh the default shell
chsh -s $(which zsh)

# oh-my-zsh and plugins
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install nodejs (for GitHub Copilot)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash
nvm install node

# Neovim
NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
NVIM_INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$NVIM_INSTALL_DIR"
echo "Downloading Nvim appimage..."
curl -Lo "$NVIM_INSTALL_DIR/nvim" "$NVIM_APPIMAGE_URL"
chmod +x "$NVIM_INSTALL_DIR/nvim"

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -

# KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc

apt update
apt install -y spotify-client inkscape peek flameshot
