#!/bin/bash
apt install -y xclip build-essential libnewlib-arm-none-eabi
apt install -y zsh git kitty yadm fzf ripgrep python3-pip cargo npm luarocks
# Make zsh the default shell
chsh -s $(which zsh)

# Install oh-my-sh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install homebrew (required for gh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# (required: echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gh

# Install Neovim
cargo install --git https://github.com/MordechaiHadad/bob.git
bob install nightly

# Neovim related packages
luarocks --lua-version=5.1 install vusted
cargo install stylua
pip3 install neovim black isort trash-cli
npm install --save-dev --save-exact prettier

# Install Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
apt update

apt install -y spotify-client inkscape peek flameshot filezilla openvpn

# Install Discord
wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
apt install -y /tmp/discord.deb

# Install Zoom
wget -P /tmp "https://zoom.us/client/latest/zoom_amd64.deb"
apt install -y /tmp/zoom_amd64.deb

# Install Hamster
wget -O /tmp/hamster.deb "http://archive.ubuntu.com/ubuntu/pool/universe/h/hamster-time-tracker/hamster-time-tracker_3.0.2-3_all.deb"
apt install -y /tmp/hamster.deb

echo "Setup GitHub SSH key?";
select yn in "yes" "no";
do
    case $yn in
        yes ) ssh-keygen -t ed25519 -C "jonas.strittmatter@gmx.de";
              eval "$(ssh-agent -s)";
              ssh-add ~/.ssh/id_ed25519;
              cat ~/.ssh/id_ed25519.pub | xclip -i -selection clipboard;
              echo ¨Copied SSH key to clipboard¨;
              read -p "Press enter to continue";
              break;;
        no ) break;;
    esac
done

echo "Clone repositories?";
select yn in "yes" "no";
do
    case $yn in
        yes ) yadm clone git@github.com:smjonas/dotfiles.git --recursive;
              # Clear font cache
              fc-cache -f -v;
              git clone git@github.com:smjonas/inacon.git ~/Desktop/Inacon;
              git clone git@github.com:smjonas/snippet-converter.nvim ~/Desktop/NeovimPlugins/snippet-converter.nvim;
              git clone git@github.com:smjonas/inc-rename.nvim ~/Desktop/NeovimPlugins/inc-rename.nvim;
              git clone git@github.com:smjonas/live-command.nvim ~/Desktop/NeovimPlugins/live-command.nvim;
              break;;
        no ) break;;
    esac
done
