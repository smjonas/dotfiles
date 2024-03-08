#!/bin/bash

# Check if a file is selected
if [ -z "$1" ]; then
  echo "No file selected." >&2
  exit 1
fi

# Check if the selected file exists
if [ ! -e "$1" ]; then
  echo "File does not exist: $1" >&2
  exit 1
fi

is_socket_active() {
  if [ -S "$1" ]; then
    # Attempt to list Kitty windows as a test command
    if kitty @ --to "unix:$1" ls &> /dev/null; then
      # If the command succeeds, the socket is active
      return 0
    fi
    # If the command fails, the socket is not active
    return 1
  else
    # Socket file does not exist
    return 1
  fi
}

KITTY_SOCKET="/tmp/single_instance_kitty"
# Use the function before deciding to launch a new Kitty instance or connect to an existing one
if is_socket_active "$KITTY_SOCKET"; then
  # Open the selected file in a new tab using kitten @
  kitty @ --to "unix:$KITTY_SOCKET" launch --type=tab --title "Neovim" nvim "$1" &> /dev/null
else
  # Remove the stale socket file
  rm -f "$KITTY_SOCKET"
  # Launch a new Kitty instance with the specified socket
  kitty -o allow_remote_control=yes --listen-on "unix:$KITTY_SOCKET" --title "Neovim" nvim "$1"
fi
