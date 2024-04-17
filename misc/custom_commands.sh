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

# Custom fzf finder to view diff given NCP number
fco() {
  local commit_pattern="$1"
  git log --oneline --format="%h %s" |
    grep "$commit_pattern" | fzf \
    --preview 'git show --format="" {1} | delta --hunk-header-style=raw --hunk-header-decoration-style=none file-decoration-style=none'\
    --preview-window="right:60%"\
    --height=80%\
    --min-height=15\
    --with-nth=2..\
    --border=none
}
