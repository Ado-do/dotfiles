#!/usr/bin/env bash
# Freeze mode: keyboard and mouse blocked while the screen stays on and its
# content visible (swaylock covers it). Toggled with a secret combo
# ($mod+Ctrl+Escape), not a password.
#   - sway mode "frozen" (66-mode-frozen.conf): only the combo, media keys and the lid
#   - pointer and touchpad input disabled in sway
#   - freeze-overlay.py: transparent layer-shell surfaces that take the
#     keyboard, so unbound keys never reach the focused window; relaunched
#     if it dies while frozen
# Idle timeouts and dunst notifications are paused meanwhile and put back
# as they were.
#
# Usage: freeze.sh on|off|toggle
#
# If it ever gets stuck: switch to a TTY (Ctrl+Alt+F3), log in and run
#   SWAYSOCK=$(echo /run/user/$UID/sway-ipc.*.sock) ~/.config/sway/scripts/freeze.sh off
#
# Requires: python3-gobject, gtk3, gtk-layer-shell, dunst, setsid

scripts="$HOME/.config/sway/scripts"
overlay="$scripts/freeze-overlay.py"
state="${XDG_RUNTIME_DIR:-/tmp}/sway-freeze.state" # supervisor pid, idle was running (0/1), dunst was paused
ready="${XDG_RUNTIME_DIR:-/tmp}/sway-freeze.ready"

on() {
    [[ -e $state ]] && return
    : >"$state"
    rm -f "$ready"

    # Supervisor in its own process group: relaunches the overlay while the
    # state file exists; off() kills the whole group
    # shellcheck disable=SC2016 # expanded by the inner bash
    setsid bash -c 'while [[ -e $1 ]]; do python3 -I "$2" "$3"; [[ -e $1 ]] && sleep 0.5; done' \
        _ "$state" "$overlay" "$ready" >/dev/null 2>&1 &
    local pid=$!

    for _ in {1..30}; do
        [[ -e $ready ]] && break
        sleep 0.1
    done
    if [[ ! -e $ready ]]; then
        rm -f "$state"
        kill -- -"$pid" 2>/dev/null
        notify-send -u critical Freeze 'The overlay did not start: input is NOT blocked'
        return 1
    fi

    local idle=0 dunst
    "$scripts/idle.sh" running && idle=1
    dunst=$(dunstctl is-paused)
    printf '%s\n' "$pid" "$idle" "$dunst" >"$state"

    "$scripts/idle.sh" stop
    pkill -RTMIN+9 waybar
    dunstctl set-paused true
    pkill -RTMIN+8 waybar
    swaymsg -q 'input type:pointer events disabled; input type:touchpad events disabled; mode frozen'
}

# Also safe without a state file (recovery from a TTY): then only sway's
# mode and input are restored.
off() {
    local pid idle dunst
    { read -r pid && read -r idle && read -r dunst; } <"$state" 2>/dev/null
    rm -f "$state" "$ready"

    swaymsg -q 'mode default; input type:pointer events enabled; input type:touchpad events enabled'
    [[ -n $pid ]] && kill -- -"$pid" 2>/dev/null

    if [[ $idle == 1 ]]; then
        "$scripts/idle.sh" start
        pkill -RTMIN+9 waybar
    fi
    if [[ $dunst == true || $dunst == false ]]; then
        dunstctl set-paused "$dunst"
        pkill -RTMIN+8 waybar
    fi
}

case "$1" in
    on) on ;;
    off) off ;;
    toggle) if [[ -e $state ]]; then off; else on; fi ;;
    *)
        echo "usage: ${0##*/} on|off|toggle" >&2
        exit 1
        ;;
esac
