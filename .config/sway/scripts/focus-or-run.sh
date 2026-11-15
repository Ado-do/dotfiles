#!/usr/bin/env bash
# Focus a window if it's open; otherwise switch to a workspace and launch it.
#
# Usage: focus-or-run.sh <criteria> <workspace|-> <command> [args...]
#   criteria   sway criteria matching the window, e.g. '[app_id="^rmpc$"]'
#   workspace  workspace number to launch on, or - to stay on the current one
#   e.g. focus-or-run.sh '[app_id="^sys_btop$"]' 10 foot -a sys_btop btop

if [ $# -lt 3 ]; then
    echo "usage: ${0##*/} <criteria> <workspace|-> <command> [args...]" >&2
    exit 1
fi

criteria=$1 ws=$2
shift 2

swaymsg "$criteria focus" >/dev/null 2>&1 && exit

[ "$ws" != - ] && swaymsg "workspace number $ws" >/dev/null
exec "$@"
