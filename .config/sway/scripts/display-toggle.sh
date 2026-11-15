#!/usr/bin/env bash
# Pick a display layout with fuzzel ($mod+o).

# Let $mod+o be released before fuzzel grabs the keyboard
sleep 0.2

# Function to send notifications
send_notification() {
    notify-send -u low -t 2000 "Display Configuration" "$1"
}

# Logical width of an output (0 while it is disabled)
output_width() {
    swaymsg -t get_outputs | jq -r --arg o "$1" '.[] | select(.name == $o) | .rect.width'
}

# Get output names: the laptop panel and the first other connected output
LAPTOP="eDP-1"
EXTERNAL=$(swaymsg -t get_outputs | jq -r --arg l "$LAPTOP" '[.[] | select(.name != $l)][0].name // empty')

if [ -z "$EXTERNAL" ]; then
    send_notification "No external monitor detected."
    exit 1
fi

# "<glyph> Label<TAB>Label": fuzzel shows column 1 and returns column 2
CHOICE=$(printf '%s\t%s\n' \
    "󰁨  Auto (kanshi)" "Auto (kanshi)" \
    "󱇽  Mirror" "Mirror" \
    "󰁍  Extend (Left)" "Extend (Left)" \
    "󰁔  Extend (Right)" "Extend (Right)" \
    "󰍹  Only External" "Only External" \
    "󰌢  Only Laptop" "Only Laptop" |
    fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" --dmenu --mesg "Display · $EXTERNAL" \
        --with-nth=1 --accept-nth=2 -w 32)

# Cancelled: keep the current setup (including an active mirror)
[ -z "$CHOICE" ] && exit 0

# Check if wl-mirror is installed
if [ "$CHOICE" = "Mirror" ] && ! command -v wl-mirror &>/dev/null; then
    send_notification "Error: wl-mirror is not installed."
    exit 1
fi

# Clean up any existing mirror windows before switching modes
pkill -x wl-mirror

case "$CHOICE" in
    "Auto (kanshi)")
        # Re-apply the kanshi profile matching the connected outputs
        if kanshictl reload; then
            send_notification "Applied kanshi profile"
        else
            send_notification "kanshi: no matching profile (or kanshi not running)"
        fi
        ;;

    "Mirror")
        # 1. Enable external monitor to the right of the laptop
        swaymsg output "$LAPTOP" enable pos 0 0
        swaymsg output "$EXTERNAL" enable pos "$(output_width "$LAPTOP")" 0

        # 2. Launch wl-mirror in background
        wl-mirror "$LAPTOP" &

        # 3. Give the window a moment to map, then move to external and fullscreen
        sleep 0.5
        swaymsg "[app_id=\"at.yrlf.wl_mirror\"] move window to output $EXTERNAL, fullscreen enable"

        send_notification "Mirroring to $EXTERNAL via wl-mirror"
        ;;

    "Extend (Left)")
        # Enable first: a disabled output reports width 0
        swaymsg output "$EXTERNAL" enable pos 0 0
        swaymsg output "$LAPTOP" enable pos "$(output_width "$EXTERNAL")" 0
        send_notification "Extended to the Left"
        ;;

    "Extend (Right)")
        swaymsg output "$LAPTOP" enable pos 0 0
        swaymsg output "$EXTERNAL" enable pos "$(output_width "$LAPTOP")" 0
        send_notification "Extended to the Right"
        ;;

    "Only External")
        swaymsg output "$EXTERNAL" enable pos 0 0
        swaymsg output "$LAPTOP" disable
        send_notification "External Monitor Only"
        ;;

    "Only Laptop")
        swaymsg output "$LAPTOP" enable pos 0 0
        swaymsg output "$EXTERNAL" disable
        send_notification "Laptop Screen Only"
        ;;

    *)
        exit 0
        ;;
esac
