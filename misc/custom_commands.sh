update_nvim() {
    curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage -o ~/Downloads/nvim.appimage
    chmod +x ~/Downloads/nvim.appimage
    mv ~/Downloads/nvim.appimage ~/.local/bin/nvim
}

update_discord() {
  wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
  apt install -y /tmp/discord.deb
}

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

zsh_history_fix() {
    cd ~
    mv .zsh_history .zsh_history_bad
    strings .zsh_history_bad > .zsh_history
    fc -R .zsh_history
    rm ~/.zsh_history_bad
}

# Sync current branch with dev: checkout dev, pull, checkout back, merge dev in
# In a worktree where dev is checked out elsewhere, fetch + merge origin/dev instead
syncdev() {
  local branch=$(git branch --show-current)
  if [[ "$branch" == "dev" ]]; then
    git pull
  elif git worktree list --porcelain | grep -q '^branch refs/heads/dev$'; then
    git fetch origin dev && git merge origin/dev
  else
    git checkout dev && git pull && git checkout "$branch" && git merge dev
  fi
}

# Create a GitLab MR from the current branch into dev, using this org's "DEV NCP-xxxx: <desc>" title convention
createmr() {
  local branch=$(git branch --show-current)
  local ticket=$(grep -oE 'NCP-[0-9]+' <<< "$branch")
  if [[ -z "$ticket" ]]; then
    echo "Current branch '$branch' has no NCP-xxxx ticket number" >&2
    return 1
  fi
  local desc=$(python3 scripts/fetch_jira_ticket.py "$ticket" 2>/dev/null | grep '^Summary:' | sed 's/^Summary:  *//')
  vared -p "Short description: " desc
  glab mr create --source-branch "$branch" --target-branch dev --title "DEV ${ticket}: ${desc}" --description "" --push --yes --remove-source-branch --squash-before-merge
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
