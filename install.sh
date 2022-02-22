#!/bin/bash
apt install -y xclip build-essential libnewlib-arm-none-eabi
apt install -y git kitty yadm fzf ripgrep python3-pip cargo npm luarocks

# Neovim related packages
cargo install stylua
pip3 install neovim black isort trash-cli
npm install --save-dev --save-exact prettier

# Install Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
apt update

apt install -y spotify-client inkscape peek flameshot filezilla

# Install Discord
wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
apt install -y /tmp/discord.deb

# Install Hamster
wget -O /tmp/hamster.deb http://archive.ubuntu.com/ubuntu/pool/universe/h/hamster-time-tracker/hamster-time-tracker_3.0.2-3_all.deb
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
        yes ) yadm clone git@github.com:smjonas/dotfiles.git;
              git clone git@github.com:smjonas/inacon.git ~/Desktop/Inacon;
              git clone git@github.com:smjonas/snippet-converter.nvim ~/Desktop/NeovimPlugins/snippet-converter.nvim;
              break;;
        no ) break;;
    esac
done
