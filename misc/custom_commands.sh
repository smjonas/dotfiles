create_ssh_key() {
    read "email?Enter your email address to use: "
    read "key_file_name?Enter the key file name (default: id_ed25519): "
    : ${key_file_name:=id_ed25519}
    ssh-keygen -t ed25519 -f ~/.ssh/$key_file_name -C "$email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/$key_file_name
    cat ~/.ssh/$key_file_name.pub | xclip -i -selection clipboard
    echo 'Copied SSH key to clipboard'
}
