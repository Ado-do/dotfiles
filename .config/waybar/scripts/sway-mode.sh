#!/usr/bin/env bash
# Sway binding mode for the custom/mode module. Replaces waybar's sway/mode,
# which gives every mode the same #mode style, so a mode can have its own
# class (#custom-mode.frozen blinks, common.css). Prints one JSON line per
# mode change; the default mode prints empty text, which hides the module.
#
# Requires: swaymsg, jq

{
    swaymsg -t get_binding_state | jq -r .name
    swaymsg -t subscribe -m '["mode"]' | jq --unbuffered -r .change
} | jq --unbuffered -Rc 'if . == "default" then {text: ""} else {text: ., class: ., tooltip: "Mode: \(.)"} end'
