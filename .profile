# ~/.profile
#
# The environment itself now lives in one place, so that login shells,
# interactive non-login shells and the systemd user session stay consistent:
#
#   ~/.config/shell/env.sh              <- actual variables (sourced below)
#   ~/.config/environment.d/10-xdg.conf <- same values for systemd --user
#
# ~/.config/sway/environment still sources this file, so sway and everything it
# launches keep inheriting the environment as before.
#
# Backup of the previous monolithic version:
#   ~/.local/state/config-backup-20260926-141609/.profile

if [ -f "$HOME/.config/shell/env.sh" ]; then
    . "$HOME/.config/shell/env.sh"
fi
