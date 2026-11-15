# ~/.bash_profile

# 1. Load the pure environment variables
[ -f ~/.profile ] && . "$HOME/.profile"

# 2. Load the interactive shell configurations
# This ensures aliases and functions are available in login shells.
[ -f ~/.bashrc ] && . "$HOME/.bashrc"

