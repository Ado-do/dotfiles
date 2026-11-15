#!/usr/bin/env bash
# Switch the default audio output (fuzzel). The current one is marked with ●.

default=$(pactl get-default-sink)

# One "marker glyph description <TAB> sink name" line per output; the glyph
# follows the device type (bluetooth, HDMI/DP, headphones, else speakers)
list=$(pactl -f json list sinks | jq -r --arg def "$default" '
    .[]
    | ((.active_port // "") + " " + .name | ascii_downcase) as $id
    | (if .properties["device.bus"] == "bluetooth" then "󰂯"
       elif ($id | test("hdmi|displayport")) then "󰔂"
       elif ($id | test("head")) or (.properties["device.form_factor"] // "" | test("head")) then "󰋋"
       else "󰓃" end) as $glyph
    | "\(if .name == $def then "●" else " " end) \($glyph)  \(.description)\t\(.name)"')

# Fuzzel shows the description and returns the sink name
sink=$(printf '%s\n' "$list" | fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" --dmenu --mesg "Audio output" \
    --with-nth=1 --accept-nth=2 -w 50)

# Exit quietly if nothing selected
[ -z "$sink" ] && exit 0

if pactl set-default-sink "$sink"; then
    name=$(pactl -f json list sinks | jq -r --arg s "$sink" '.[] | select(.name == $s) | .description')
    notify-send "Audio Switched" "Active Output: $name" -i audio-speakers
else
    notify-send "Audio Switcher" "Failed to switch to $sink." -i dialog-error
fi
