#!/bin/bash
apt update
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

# Install nodejs (for GitHub Copilot)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash
nvm install node

echo "Install IntelliJ";
select yn in "yes" "no";
do
  case $yn in
    yes )
      INTELLIJ_INSTALL_DIR = "/opt/idea";
      wget -c https://www.jetbrains.com/de-de/idea/download/download-thanks.html?platform=linux -P /tmp;
      mkdir -p $INTELLIJ_INSTALL_DIR;
      tar -xf /tmp/ideaIC-*.tar.gz -C $INTELLIJ_INSTALL_DIR --strip-components=1;
      rm /tmp/ideaIC-*.tar.gz;
      # Create a symbolic link to make it easier to run IntelliJ
      ln -s "$INTELLIJ_INSTALL_DIR/bin/idea.sh" /usr/local/bin/idea;
      # Provide permissions to the installation directory
      chown -R $USER:$USER $INTELLIJ_INSTALL_DIR;
      break;;
    no ) break;;
  esac
done

# Rust (rustup for cargo)
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
chmod +x ~/.local/bin/rust-analyzer

# Neovim
NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
NVIM_INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$NVIM_INSTALL_DIR"
echo "Downloading Nvim appimage..."
curl -Lo "$NVIM_INSTALL_DIR/nvim" "$NVIM_APPIMAGE_URL"
chmod +x "$NVIM_INSTALL_DIR/nvim"

# Neovim-related packages
luarocks --lua-version=5.1 install vusted
cargo install stylua
pip3 install basedpyright mypy trash-cli "ruff>=0.5.3"
npm install --save-dev --save-exact prettier
curl -fsSL https://deno.land/install.sh | sh

# PHP + formatter
apt install php-common libapache2-mod-php php-cli
wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O php-cs-fixer
chmod a+x php-cs-fixer
mv php-cs-fixer /usr/local/bin/php-cs-fixer

# zellij
cargo install --locked zellij

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# git delta
wget -P /tmp https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_amd64.deb
apt install -y /tmp/git-delta_0.17.0_amd64.deb

# thefuck
apt update
apt install python3-dev python3-pip python3-setuptools
pip3 install thefuck --user

# KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc

# Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -

apt install -y spotify-client inkscape peek flameshot openvpn keepassxc

# Discord
wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
apt install -y /tmp/discord.deb

# Obsidian
wget -O /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.8.4/obsidian_1.8.4_amd64.deb"
apt install -y /tmp/obsidian.deb

echo "Install Inacon-specific stuff (htpasswd, Zoom, FileZilla)?";
select yn in "yes" "no";
do
  case $yn in
    yes )
      # htpasswd
      apt install apache2-utils;
      # Zoom + Filezilla
      wget -P /tmp "https://zoom.us/client/latest/zoom_amd64.deb";
      apt install -y /tmp/zoom_amd64.deb filezilla;
      break;;
    no ) break;;
  esac

# Hamster
wget -O /tmp/hamster.deb "http://archive.ubuntu.com/ubuntu/pool/universe/h/hamster-time-tracker/hamster-time-tracker_3.0.2-3_all.deb"
apt install -y /tmp/hamster.deb

# htpasswd
echo "Clone repositories?";
select yn in "yes" "no";
do
    case $yn in
        yes ) yadm clone git@github.com:smjonas/dotfiles.git --recursive ~/dotfiles;
              git clone git@github.com:smjonas/inacon.git ~/Desktop/Inacon;
              git clone git@github.com:smjonas/snippet-converter.nvim ~/Desktop/NeovimPlugins/snippet-converter.nvim;
              git clone git@github.com:smjonas/inc-rename.nvim ~/Desktop/NeovimPlugins/inc-rename.nvim;
              git clone git@github.com:smjonas/live-command.nvim ~/Desktop/NeovimPlugins/live-command.nvim;
              break;;
        no ) break;;
    esac
done
