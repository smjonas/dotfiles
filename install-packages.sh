#!/bin/bash
apt install -y build-essential libnewlib-arm-none-eabi
apt install -y zsh kitty fzf ripgrep fdfind python3-pip luarocks
# htpasswd
apt install apache2-utils

# https://github.com/sharkdp/fd#on-debian
ln -s $(which fdfind) ~/.local/bin/fd

# Make zsh the default shell
chsh -s $(which zsh)

# oh-my-zsh and plugins
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install nodejs (for GitHub Copilot)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash
nvm install node

# Rust (rustup for cargo)
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.cargo/bin/rust-analyzer
chmod +x ~/.cargo/bin/rust-analyzer

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
luarocks --lua-version=5.1 install vusted
cargo install stylua
pip3 install neovim black isort trash-cli
npm install --save-dev --save-exact prettier

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -

# KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc

apt update
apt install -y spotify-client inkscape peek flameshot filezilla openvpn keepassxc

# Discord
wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
apt install -y /tmp/discord.deb

# Zoom
wget -P /tmp "https://zoom.us/client/latest/zoom_amd64.deb"
apt install -y /tmp/zoom_amd64.deb

# Hamster
wget -O /tmp/hamster.deb "http://archive.ubuntu.com/ubuntu/pool/universe/h/hamster-time-tracker/hamster-time-tracker_3.0.2-3_all.deb"
apt install -y /tmp/hamster.deb

echo "Clone repositories?";
select yn in "yes" "no";
do
    case $yn in
        yes ) yadm clone git@github.com:smjonas/dotfiles.git --recursive;
              git clone git@github.com:smjonas/inacon.git ~/Desktop/Inacon;
              git clone git@github.com:smjonas/snippet-converter.nvim ~/Desktop/NeovimPlugins/snippet-converter.nvim;
              git clone git@github.com:smjonas/inc-rename.nvim ~/Desktop/NeovimPlugins/inc-rename.nvim;
              git clone git@github.com:smjonas/live-command.nvim ~/Desktop/NeovimPlugins/live-command.nvim;
              break;;
        no ) break;;
    esac
done
