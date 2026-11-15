#!/bin/bash

# waybar custom/dunst: a bell, with class "paused" while dunst is paused
# so themes can style it (Nerd Font glyphs: bell / bell-slash)
ENABLED=$''
DISABLED=$''

if [ "$(dunstctl is-paused)" = "true" ]; then
    printf '{"text": "%s", "class": "paused"}\n' "$DISABLED"
else
    printf '{"text": "%s"}\n' "$ENABLED"
fi
