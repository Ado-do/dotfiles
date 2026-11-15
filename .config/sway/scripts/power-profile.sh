#!/usr/bin/env bash
# Cycle the TLP power profile (via tlp-pd) and notify.
# TLP still switches to performance on AC and power-saver on battery when the
# charger is plugged/unplugged (TLP_AUTO_SWITCH=1 in /etc/tlp.conf).

profiles=(performance balanced power-saver)

# tlp-pd applies the profile asynchronously (~200ms), so serialize quick
# repeated presses and wait for each switch to land before reading the next
exec {lock}>"${XDG_RUNTIME_DIR:-/tmp}/power-profile.lock"
flock "$lock"

current=$(tlpctl get) || exit 1

# Next profile after the current one (wraps around)
next=${profiles[0]}
for i in "${!profiles[@]}"; do
    if [ "${profiles[i]}" = "$current" ]; then
        next=${profiles[(i + 1) % ${#profiles[@]}]}
        break
    fi
done

case $next in
    performance) icon=power-profile-performance-symbolic ;;
    balanced) icon=power-profile-balanced-symbolic ;;
    power-saver) icon=power-profile-power-saver-symbolic ;;
esac

if tlpctl set "$next" >/dev/null; then
    for _ in {1..20}; do
        [ "$(tlpctl get)" = "$next" ] && break
        sleep 0.1
    done
    notify-send "Power Profile" "Switched to $next" -i "$icon" \
        -h string:x-dunst-stack-tag:power_profile
else
    notify-send "Power Profile" "Failed to switch to $next." -i dialog-error
fi
