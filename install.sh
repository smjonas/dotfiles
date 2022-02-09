echo Remember to add ~/.local/bin and ~/.cargo/bin to path! export PATH="$HOME/mypath:$PATH"
read -p "Press enter to start";

#!/bin/bash
apt install -y xclip build-essential libnewlib-arm-none-eabi
apt install -y git kitty yadm fzf ripgrep python3-pip cargo npm

# Neovim related packages
cargo install stylua
pip3 install neovim black isort
npm install --save-dev --save-exact prettier

# Install Spotify
sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list'
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
apt update
apt install spotify-client inkscape

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
              git clone git@github.com:smjonas/snippet-converter.nvim ~/Desktop/NeovimPlugins/snippet-converter;
              break;;
        no ) break;;
    esac
done



