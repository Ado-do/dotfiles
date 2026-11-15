#!/bin/bash

# Switch the waybar theme by pointing style.css at common.css plus a file
# in themes/.
# Usage: theme.sh           (pick a theme with fuzzel)
#        theme.sh <name>    (switch directly, e.g. neutral|minimal|stock)

DIR="$HOME/.config/waybar"
STYLE="$DIR/style.css"

THEMES=$(find "$DIR/themes" -maxdepth 1 -name '*.css' -printf '%f\n' | sed 's/\.css$//' | sort)
CURRENT=$(sed -n 's|.*themes/\(.*\)\.css.*|\1|p' "$STYLE" 2>/dev/null) # style.css is untracked; may not exist yet

if [ -n "$1" ]; then
    CHOICE="$1"
else
    # "<marker> name<TAB>name", the current theme marked with ●
    CHOICE=$(printf '%s\n' "$THEMES" | awk -v cur="$CURRENT" '{ printf "%s %s\t%s\n", ($0 == cur ? "●" : " "), $0, $0 }' \
        | fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" --dmenu --mesg "Waybar theme" \
            --with-nth=1 --accept-nth=2 -w 30)
fi

[ -z "$CHOICE" ] && exit 0

if [ ! -f "$DIR/themes/$CHOICE.css" ]; then
    msg="unknown theme: $CHOICE (available: $(printf '%s\n' "$THEMES" | paste -sd ' '))"
    echo "$msg" >&2
    # usually launched from a keybind, where stderr goes nowhere
    notify-send -a waybar "Waybar theme" "$msg"
    exit 1
fi

printf '@import url("common.css");\n@import url("themes/%s.css");\n' "$CHOICE" > "$STYLE"

# Drop leftover preview instances started with -s, then reload sway's bar
pkill -f '^waybar -s'
pkill -SIGUSR2 -x waybar
