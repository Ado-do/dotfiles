#!/usr/bin/env bash

# File paths
RULES_FILE="$HOME/.config/sway/config.d/55-rules-float-persist.conf"

# Helper for notifications
send_notification() {
    notify-send -u normal -t 3000 "Permanent Float" "$1"
}

# 1. Pick a window: fuzzel shows the title with the app icon, matches the app
# name too, and returns the con_id
# Format: con_id <TAB> title <TAB> app <TAB> icon fallbacks
con_id=$(swaymsg -t get_tree | jq -r '
  .. | select(.type? == "con" or .type? == "floating_con") 
  | select(.name != null and (.app_id != null or .window_properties.class != null)) 
  | (.app_id // .window_properties.class) as $app
  | "\(.id)\t\(.name | gsub("[\t\n]"; " ") | if . == "" then "(untitled)" else . end)\t\($app)\t\($app),\($app | ascii_downcase),\($app | split(".") | last | ascii_downcase),application-x-executable"' |
    while IFS=$'\t' read -r id title app icon; do
        printf '%s\t%s\t%s\0icon\x1f%s\n' "$id" "$title" "$app" "$icon"
    done |
    fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" -d --mesg "Make persistently floating" \
        --with-nth=2 --accept-nth=1 --match-nth="{2} {3}" -w 80)

# Exit quietly if nothing selected
[ -z "$con_id" ] && exit 0

# 2. The selection is the container ID itself
if [[ ! $con_id =~ ^[0-9]+$ ]]; then
    send_notification "Error: Could not extract window ID."
    exit 1
fi

# 3. Retrieve app_id and class from Sway using the con_id
window_info=$(swaymsg -t get_tree | jq -r --argjson target_id "$con_id" '
  .. | select(.id? == $target_id) | "\(.app_id // "null")|\(.window_properties.class // "null")"')

app_id=$(echo "$window_info" | cut -d'|' -f1)
class=$(echo "$window_info" | cut -d'|' -f2)

# Determine the best identifier to use (prefer app_id for Wayland, class for XWayland)
if [ "$app_id" != "null" ] && [ -n "$app_id" ]; then
    rule_type="app_id"
    rule_val="$app_id"
elif [ "$class" != "null" ] && [ -n "$class" ]; then
    rule_type="class"
    rule_val="$class"
else
    send_notification "Error: Could not find a valid app_id or class for this window."
    exit 1
fi

# Quotes or backslashes would break the config line
if [[ "$rule_val" == *[\"\\]* ]]; then
    send_notification "Error: unsupported characters in ${rule_type} '${rule_val}'."
    exit 1
fi

# 4. Construct and append the rule (anchored, regex metacharacters escaped)
rule_re=$(printf '%s' "$rule_val" | sed 's#[]^$.*+?(){}|/[]#\\&#g')
CRITERIA="[${rule_type}=\"^${rule_re}\$\"]"
RULE="for_window $CRITERIA floating enable"

# Ensure the rules file exists
mkdir -p "$(dirname "$RULES_FILE")"
[ -f "$RULES_FILE" ] || printf '# Persistently floating windows\n# Managed by scripts/float-window-persist.sh\n' >"$RULES_FILE"

# Check every config file: another rule with the same criteria may already float it
existing=$(grep -HF "for_window $CRITERIA" "$(dirname "$RULES_FILE")"/*.conf | grep -m1 'floating enable' | cut -d: -f1)
if [ -n "$existing" ]; then
    send_notification "Rule already exists for ${rule_val} in ${existing##*/}."
else
    # Append the rule to the rules file
    echo "$RULE" >>"$RULES_FILE"
    send_notification "Added permanent float rule for ${rule_val}."

    # Reload Sway configuration to apply the rule for future windows
    swaymsg reload
fi

# 5. Apply floating mode to the current window immediately
swaymsg "[con_id=$con_id] floating enable"
