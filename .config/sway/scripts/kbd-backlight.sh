#!/usr/bin/env bash
# Keyboard backlight off/restore for swayidle.
#   off      remember the current level (unless already remembered), then set 0
#   restore  set the remembered level back and forget it; a few seconds later,
#            set it again if something (firmware on resume / lid open) dropped it
# Safe to call repeatedly: swayidle can fire two power-off timeouts in a row,
# and both swayidle instances (idle.sh and 90-swayidle.conf) call this script.
# Optional 2nd argument: a tag for the log (who called it).
# Log: ~/.cache/kbd-backlight.log

DEV="*kbd_backlight*"
saved="${XDG_RUNTIME_DIR:-/tmp}/kbd-backlight-level"
lock="${XDG_RUNTIME_DIR:-/tmp}/kbd-backlight.lock"
log="${XDG_CACHE_HOME:-$HOME/.cache}/kbd-backlight.log"
recheck=5  # seconds after restore to check the level again

get() { brightnessctl -d "$DEV" get; }
set_level() { brightnessctl -q -d "$DEV" set "$1"; }
say() {
    printf '%s %-7s %-12s %s\n' "$(date '+%F %T')" "$action" "${tag:--}" "$*" >> "$log"
    # keep the log small
    (( $(wc -l < "$log") > 500 )) && sed -i '1,100d' "$log"
}

action=$1 tag=$2
exec 9> "$lock"
flock 9

case "$action" in
off)
    now=$(get)
    if [ -e "$saved" ]; then
        say "level=$now kept saved=$(< "$saved")"
    else
        echo "$now" > "$saved.tmp" && mv "$saved.tmp" "$saved"
        say "level=$now saved"
    fi
    set_level 0
    ;;
restore)
    if [ ! -e "$saved" ]; then
        say "nothing saved, level=$(get)"
        exit 0
    fi
    level=$(< "$saved")
    rm -f "$saved"
    set_level "$level"
    say "set $level, now=$(get)"
    # Firmware can reset the light shortly after resume or when the lid opens.
    # Re-apply unless a new "off" happened meanwhile.
    (
        sleep "$recheck"
        exec 9> "$lock"; flock 9
        [ -e "$saved" ] && exit 0
        now=$(get)
        if (( now < level )); then
            set_level "$level"
            action=recheck say "dropped to $now, set $level again, now=$(get)"
        else
            action=recheck say "ok, level=$now"
        fi
    ) 9>&- >/dev/null 2>&1 &
    ;;
*)
    echo "usage: $0 off|restore [tag]" >&2; exit 1 ;;
esac
