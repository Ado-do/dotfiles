#!/usr/bin/env bash
# Session/power menu (fuzzel). Nothing happens unless an entry is picked.

# "<glyph> Label<TAB>Label": fuzzel shows column 1 and returns column 2
CHOICE=$(printf '%s\t%s\n' \
    "󰌾  Lock" Lock \
    "󰍃  Logout" Logout \
    "󰤄  Suspend" Suspend \
    "󰜉  Reboot" Reboot \
    "󰐥  Shutdown" Shutdown |
    fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" --dmenu --mesg "Power" \
        --with-nth=1 --accept-nth=2 -w 24 --border-color=f0607aff)

case "$CHOICE" in
"Lock")     loginctl lock-session ;;  # handled by swayidle's lock hook
"Logout")   swaymsg exit ;;
"Suspend")  systemctl suspend ;;      # swayidle locks before sleep
"Reboot")   systemctl reboot ;;
"Shutdown") systemctl poweroff ;;
*)          exit 0 ;;
esac
