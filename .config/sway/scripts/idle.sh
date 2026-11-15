#!/usr/bin/env bash
# "Always awake" toggle. Runs the swayidle instance that handles the idle
# timeouts (lock, screens off); stopping it keeps the machine awake. Locking
# before sleep / on lock-session is a separate swayidle (90-swayidle.conf)
# and keeps working either way.
#
# Usage: idle.sh start|stop|toggle|running|status
#   running exits 0 if the timeouts are active (used by freeze.sh).
#   status prints JSON for waybar's custom/idle module (signal 9).
#
# Requires: swayidle, swaylock, setsid, brightnessctl

lock_timeout=180   # idle seconds before locking
screen_timeout=60  # seconds before screens turn off (after locking, or while locked)
dim_warning=15     # seconds before locking that the screen dims as a warning

scripts="$HOME/.config/sway/scripts"
pidfile="${XDG_RUNTIME_DIR:-/tmp}/sway-idle-timeouts.pid"

running() {
    local pid
    { read -r pid < "$pidfile"; } 2>/dev/null || return 1
    [[ $(ps -o comm= -p "$pid" 2>/dev/null) == swayidle ]]
}

start() {
    running && return
    local lt=$lock_timeout st=$screen_timeout
    local off="swaymsg 'output * power off'; $scripts/kbd-backlight.sh off idle"
    local on="swaymsg 'output * power on'; $scripts/kbd-backlight.sh restore idle"
    local locked='pgrep -xu "$USER" swaylock >/dev/null'
    setsid swayidle -w \
        timeout $((lt - dim_warning)) "$scripts/screen-dim.sh dim" \
            resume "$scripts/screen-dim.sh restore" \
        timeout "$lt" 'swaylock -f' \
        timeout $((lt + st)) "$off" resume "$on" \
        timeout "$st" "$locked && { $off; }" resume "$locked && { $on; }" \
        >/dev/null 2>&1 &
    echo $! > "$pidfile"
}

stop() {
    running && kill "$(< "$pidfile")"
    rm -f "$pidfile"
}

case "$1" in
start)  start ;;
stop)   stop ;;
running) running ;;
toggle) if running; then stop; else start; fi
        pkill -RTMIN+9 waybar ;;
status) if running; then
            echo '{"alt":"deactivated","class":"deactivated","tooltip":"Idle: locks after '"$lock_timeout"'s"}'
        else
            echo '{"alt":"activated","class":"activated","tooltip":"Always awake"}'
        fi ;;
*)      echo "usage: ${0##*/} start|stop|toggle|running|status" >&2; exit 1 ;;
esac
