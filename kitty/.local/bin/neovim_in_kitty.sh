#!/bin/bash

# Log file path
LOG_FILE="$HOME/.neovim_in_kitty.log"

# Function to log messages to the log file
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}
log_message "Argument 1: $1"
# Check if a file is selected
if [ -z "$1" ]; then
  log_message "No file selected."
  exit 1
fi

# Check if the selected file exists
if [ ! -e "$1" ]; then
  log_message "File does not exist: $1"
  exit 1
fi

log_message "Selected file: $1"

is_socket_active() {
  if [ -S "$1" ]; then
    # Attempt to list Kitty windows as a test command
    if ! kitty @ --to "unix:$1" ls 2>/dev/null; then
      # If the command fails, the socket is not active
      return 1
    fi
    # If the command succeeds, the socket is active
    return 0
  else
    # Socket file does not exist
    return 1
  fi
}

KITTY_SOCKET="/tmp/mykitty3"
# Use the function before deciding to launch a new Kitty instance or connect to an existing one
if is_socket_active "$KITTY_SOCKET"; then
  log_message "Kitty socket is active."
  # Existing code to connect to the active Kitty instance
  log_message "Kitty is running with the specified socket."

  # Open the selected file in a new tab using kitten @
  log_message "Opening file in a new Kitty tab..."
  if kitty @ --to "unix:$KITTY_SOCKET" launch --type=tab --title "Neovim" nvim "$1" 2>> "$LOG_FILE"; then
      log_message "File opened successfully in a new Kitty tab."
  else
      log_message "Failed to open file in a new Kitty tab."
      log_message "Error output:"
      cat "$LOG_FILE" | tail -n 10 >> "$LOG_FILE"
  fi
else
  log_message "Kitty socket is not active or does not exist."
  # Remove the stale socket file
  rm -f "$KITTY_SOCKET"
  # Launch a new Kitty instance with the specified socket
  log_message "Launching a new Kitty instance with the specified socket..."
  kitty -o allow_remote_control=yes --listen-on "unix:$KITTY_SOCKET" --title "Neovim" nvim "$1"
fi
#
# # Check if Kitty is installed
# if command -v kitty &> /dev/null; then
#   log_message "Kitty is installed."
#
#   # Kitty socket path
#   KITTY_SOCKET="/tmp/mykitty3"
#
#   # Check if Kitty is already running with the specified socket
#   if [ -S "$KITTY_SOCKET" ]; then
#     log_message "Kitty is running with the specified socket."
#
#     # Open the selected file in a new tab using kitten @
#     log_message "Opening file in a new Kitty tab..."
#     if kitty @ --to "unix:$KITTY_SOCKET" launch --type=tab --title "Neovim" nvim "$1" 2>> "$LOG_FILE"; then
#       log_message "File opened successfully in a new Kitty tab."
#     else
#       log_message "Failed to open file in a new Kitty tab."
#       log_message "Error output:"
#       cat "$LOG_FILE" | tail -n 10 >> "$LOG_FILE"
#     fi
#   else
#     log_message "Kitty is not running with the specified socket."
#
#     # Launch a new Kitty instance with the specified socket
#     log_message "Launching a new Kitty instance with the specified socket..."
#     kitty -o allow_remote_control=yes --listen-on "unix:$KITTY_SOCKET" --title "Neovim" nvim "$1"
#   fi
# else
#   log_message "Kitty is not installed."
#   log_message "Please install Kitty or run Neovim directly with the following command:"
#   log_message "nvim \"$1\""
#   exit 1
# fi
