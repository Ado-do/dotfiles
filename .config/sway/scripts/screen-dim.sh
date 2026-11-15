#!/usr/bin/env bash
# Screen dim/restore for swayidle: a warning shortly before locking.
#   dim      remember the current level (unless already remembered), then dim
#   restore  set the remembered level back and forget it
# Safe to call repeatedly, like kbd-backlight.sh.

percent=30  # dimmed level, as a percentage of the current one

saved="${XDG_RUNTIME_DIR:-/tmp}/screen-backlight-level"

case "$1" in
dim)
    [ -e "$saved" ] || brightnessctl -c backlight get > "$saved"
    level=$(( $(cat "$saved") * percent / 100 ))
    brightnessctl -q -c backlight set "$(( level > 0 ? level : 1 ))"
    ;;
restore)
    [ -e "$saved" ] || exit 0
    brightnessctl -q -c backlight set "$(cat "$saved")"
    rm -f "$saved"
    ;;
*)
    echo "usage: $0 dim|restore" >&2; exit 1 ;;
esac
