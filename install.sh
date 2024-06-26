#!/bin/bash

echo "Installing Git and GNU Stow..."
sudo apt-get update
sudo apt-get install -y git stow

create_ssh_key="y"
while [ "$create_ssh_key" = "y" ]
do
    read -p "Enter your email address used for the SSH key (e.g. for GitHub): " email
    # Generate SSH key
    ssh-keygen -t ed25519 -C "$email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub | xclip -i -selection clipboard
    echo "Copied SSH key to clipboard"

    read -p "Do you want to create another SSH key? (yes/no): " create_ssh_key
    while [ "$create_ssh_key" != "y" ] && [ "$create_ssh_key" != "n" ]
    do
        echo "Invalid input. Please enter 'y' or 'n'."
        read -p "Do you want to create anther SSH key? (y/n): " create_ssh_key
    done
done

echo "Downloading dotfiles repository..."
git clone --recurse-submodules git@github.com:smjonas/dotfiles.git ~/dotfiles

cd ~/dotfiles

echo "Installing dotfiles..."
stow -S fonts git intellij kitty misc nvim oh-my-zsh pulse-audio zellij
# Clear font cache
fc-cache -f -v;

sudo ./install-packages.sh

echo "Dotfiles installation complete!"
