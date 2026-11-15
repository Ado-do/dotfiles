#!/usr/bin/env bash
# Open a waybar-style floating TUI panel, or focus it if it's already open.
#
# Usage: panel.sh <title> <command> [args...]
#   e.g. panel.sh Wi-Fi wlctl
#
# Used by the $mod+n panels mode and waybar's on-click (see float_panel in 50-rules.conf).

title=$1
shift

exec "$HOME/.config/sway/scripts/focus-or-run.sh" "[app_id=\"^float_panel\$\" title=\"^${title}\$\"]" - \
    foot -a float_panel -o 'font=IosevkaTerm NF:weight=medium:size=14' -T "$title" "$@"
