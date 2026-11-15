#!/usr/bin/env bash
# Per-output workspace history.
#   daemon  track the last two workspaces shown on each output (run from autostart)
#   back    switch back to the previous workspace on the focused output
#   output  focus the next output (wraps around, ordered left to right)

state="${XDG_RUNTIME_DIR:-/tmp}/sway-ws-history"
mkdir -p "$state"

track() {
    local out=$1 ws=$2 cur
    cur=$(sed -n 1p "$state/$out" 2>/dev/null)
    [ "$cur" = "$ws" ] && return
    printf '%s\n%s\n' "$ws" "$cur" > "$state/$out"
}

case "$1" in
daemon)
    # seed with what is currently visible
    swaymsg -t get_workspaces | jq -r '.[] | select(.visible) | "\(.output)\t\(.name)"' |
        while IFS=$'\t' read -r out ws; do track "$out" "$ws"; done
    swaymsg -t subscribe -m '["workspace"]' |
        jq --unbuffered -r 'select(.change == "focus") | "\(.current.output)\t\(.current.name)"' |
        while IFS=$'\t' read -r out ws; do track "$out" "$ws"; done
    ;;
back)
    out=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
    prev=$(sed -n 2p "$state/$out" 2>/dev/null)
    [ -z "$prev" ] && exit 0
    # skip if that workspace has since moved to another output
    elsewhere=$(swaymsg -t get_workspaces | jq -r --arg ws "$prev" --arg out "$out" \
        '.[] | select(.name == $ws and .output != $out) | .name')
    [ -n "$elsewhere" ] && exit 0
    swaymsg workspace "\"$prev\""
    ;;
output)
    swaymsg -t get_outputs | jq -r '
        [.[] | select(.active)] | sort_by(.rect.x, .rect.y) as $o
        | ($o | map(.focused) | index(true)) as $i
        | $o[($i + 1) % ($o | length)].name' |
        xargs -r -I{} swaymsg focus output {}
    ;;
*)
    echo "usage: $0 daemon|back|output" >&2; exit 1 ;;
esac
