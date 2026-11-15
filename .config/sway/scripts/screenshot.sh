#!/usr/bin/env bash
# Usage: screenshot.sh screen|window|area

SS_DIR="${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
NEW_SS="$SS_DIR/ss_$TIMESTAMP.png"
LINK_PATH="$SS_DIR/last_ss.png"

mkdir -p "$SS_DIR"

# Take the screenshot based on the argument passed
if [ "$1" == "area" ]; then
    GEOMETRY=$(slurp)
    # Exit cleanly if the user cancels slurp (hits Escape)
    [ -z "$GEOMETRY" ] && exit 1
    grim -g "$GEOMETRY" "$NEW_SS"
elif [ "$1" == "window" ]; then
    # Focused window's contents, without border or titlebar
    GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true and .pid != null)
        | "\(.rect.x + .window_rect.x),\(.rect.y + .window_rect.y) \(.window_rect.width)x\(.window_rect.height)"')
    # Nothing to capture on an empty workspace
    [ -z "$GEOMETRY" ] && exit 1
    grim -g "$GEOMETRY" "$NEW_SS"
else
    grim "$NEW_SS"
fi || {
    notify-send -u critical "Screenshot Failed" "grim could not capture the screen."
    exit 1
}

# Update the symbolic link (-f forces it to overwrite the existing symlink)
ln -sf "$NEW_SS" "$LINK_PATH"

# Copy the new file to the clipboard and send a notification
wl-copy <"$NEW_SS"
notify-send "Screenshot Captured" "Saved as ss_$TIMESTAMP.png."
