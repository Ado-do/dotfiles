#!/usr/bin/env bash
# Sway power event listener and notifier using UPower

# Dynamically find UPower devices
AC_DEV=$(upower -e | grep -E 'line_power|AC|ADP' | head -n 1)
BAT_DEV=$(upower -e | grep -E 'battery|BAT' | head -n 1)

[ -z "$AC_DEV" ] || [ -z "$BAT_DEV" ] && exit 1

LOW=20      # % for the low battery warning
CRITICAL=10 # % for the urgent one

LAST_AC=""
LAST_BAT_STATE=""
BAT_WARNED="" # "", low or critical: warnings already sent on this discharge

check_and_notify() {
    local ac_online bat_status bat_level
    ac_online=$(upower -i "$AC_DEV" 2>/dev/null | awk '/online:/ {print $2}')
    read -r bat_status bat_level < <(upower -i "$BAT_DEV" 2>/dev/null |
        awk '/state:/ {s = $2} /percentage:/ {gsub("%", ""); p = int($2)} END {print s, p}')

    [ -z "$ac_online" ] && return

    # Notification on AC plug/unplug transition
    if [ -n "$LAST_AC" ] && [ "$ac_online" != "$LAST_AC" ]; then
        if [ "$ac_online" = "yes" ]; then
            notify-send "Power Connected" "Your laptop is now charging (${bat_level}%)." \
                -i battery-full-charging \
                -h string:x-dunst-stack-tag:power_state
        else
            notify-send "Power Disconnected" "Running on battery power (${bat_level}%)." \
                -i battery-caution \
                -h string:x-dunst-stack-tag:power_state
        fi
        BAT_WARNED=""
    fi
    LAST_AC="$ac_online"

    # Notification on Battery Fully Charged
    if [ "$bat_status" = "fully-charged" ] && [ "$LAST_BAT_STATE" != "fully-charged" ]; then
        notify-send "Battery Full" "Your laptop is fully charged (${bat_level}%). You can unplug now." \
            -i battery-full \
            -h string:x-dunst-stack-tag:power_state
    fi
    LAST_BAT_STATE="$bat_status"

    # Low and critical battery warnings when discharging, once each
    if [ "$ac_online" = "no" ] && [ -n "$bat_level" ]; then
        if [ "$bat_level" -le "$CRITICAL" ] && [ "$BAT_WARNED" != critical ]; then
            notify-send "Battery Critical" "Battery is at ${bat_level}%. Plug in your charger now." \
                -u critical \
                -i battery-empty \
                -h string:x-dunst-stack-tag:power_state
            BAT_WARNED=critical
        elif [ "$bat_level" -le "$LOW" ] && [ -z "$BAT_WARNED" ]; then
            notify-send "Battery Low" "Battery is at ${bat_level}%. Please plug in your charger." \
                -i battery-low \
                -h string:x-dunst-stack-tag:power_state
            BAT_WARNED=low
        fi
    fi
}

# Initial check on startup
check_and_notify

# Listen continuously to UPower events (stdbuf -oL flushes lines immediately)
stdbuf -oL upower --monitor | while read -r line; do
    if [[ $line =~ line_power|battery|AC|BAT ]]; then
        check_and_notify
    fi
done
