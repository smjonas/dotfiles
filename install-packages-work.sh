#!/bin/bash
apt install -y build-essential libnewlib-arm-none-eabi
apt install -y zsh kitty fzf ripgrep fdfind python3-pip luarocks

# https://github.com/sharkdp/fd#on-debian
ln -s $(which fdfind) ~/.local/bin/fd

# Make zsh the default shell
chsh -s $(which zsh)

# oh-my-zsh and plugins
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# IntelliJ
INTELLIJ_INSTALL_DIR = "/opt/idea"
wget -c https://www.jetbrains.com/de-de/idea/download/download-thanks.html?platform=linux -P /tmp
mkdir -p $INTELLIJ_INSTALL_DIR
tar -xf /tmp/ideaIC-*.tar.gz -C $INTELLIJ_INSTALL_DIR --strip-components=1
rm /tmp/ideaIC-*.tar.gz
# Create a symbolic link to make it easier to run IntelliJ
ln -s "$INTELLIJ_INSTALL_DIR/bin/idea.sh" /usr/local/bin/idea
# Provide permissions to the installation directory
chown -R $USER:$USER $INTELLIJ_INSTALL_DIR

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

# zellij
cargo install --locked zellij

# Neovim-related packages
pip3 install black isort

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
