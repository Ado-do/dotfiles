#!/usr/bin/env bash

# Open windows with their workspace, app and title
windows=$(swaymsg -t get_tree | jq -r '
  [recurse(.nodes[]?, .floating_nodes[]?) 
   | select(.type == "workspace") 
   | .name as $raw_ws 
   | (if $raw_ws == "__i3_scratch" then "scratch" else $raw_ws end) as $ws
   | recurse(.nodes[]?, .floating_nodes[]?) 
   | select((.type == "con" or .type == "floating_con") and .name != null and (.app_id != null or .window_properties.class != null) and (.nodes | length == 0))
   | {
       id: .id, 
       ws: $ws, 
       raw: (.app_id // .window_properties.class),
       app: ((.app_id // .window_properties.class) | split(".") | last), 
       name: (.name | gsub("[\t\n]"; " "))
     }
  ] | .[] | "\(.id)\t[\(.ws)] \(.name)\t\(.app)\t\(.raw),\(.raw | ascii_downcase),\(.app | ascii_downcase),application-x-executable"
')

# No open windows: nothing to do
[ -z "$windows" ] && exit 0

# Fuzzel shows column 2 (workspace, title) with the app icon, matches the app
# name too, and returns column 1 (con_id). The icon is appended in the pipe
# because command substitution would drop its NUL byte.
selected_id=$(printf '%s\n' "$windows" |
    while IFS=$'\t' read -r id label app icon; do
        printf '%s\t%s\t%s\0icon\x1f%s\n' "$id" "$label" "$app" "$icon"
    done |
    fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" -d --mesg "Windows" \
        --with-nth=2 --accept-nth=1 --match-nth="{2} {3}" -w 70 -l 12)

# Focus the selected window
if [ -n "$selected_id" ]; then
    swaymsg "[con_id=$selected_id] focus"
fi
