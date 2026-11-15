#!/usr/bin/env bash
# Searchable list of every sway binding (fuzzel).
# Enter runs the selected binding, Alt+e (fuzzel custom-2) opens its definition in nvim.
#
# Usage: keybind-help.sh [--list]
#   --list  print the bindings and where they're defined, without fuzzel

# Same file layering as the include line in ~/.config/sway/config
files=("$HOME/.config/sway/config")
if include_list=$(/usr/libexec/sway/layered-include "/usr/share/sway/config.d/*.conf" "/etc/sway/config.d/*.conf" "$HOME/.config/sway/config.d/*.conf"); then
    while IFS= read -r inc; do
        inc=${inc#include \'}
        files+=("${inc%\'}")
    done <"$include_list"
fi

# Prints one "display \x1f command \x1f file \x1f line" record per binding
read -r -d '' parser <<'EOF'
function trim(s) {
    sub(/^[ \t]+/, "", s)
    sub(/[ \t]+$/, "", s)
    return s
}

function strip_flags(s) {
    s = trim(s)
    while (s ~ /^--/)
        sub(/^[^ \t]+[ \t]*/, "", s)
    return s
}

# Like sway: at each "$", the longest defined variable name wins
function expand(s,   out, pos, best, name) {
    out = ""
    while ((pos = index(s, "$")) > 0) {
        out = out substr(s, 1, pos - 1)
        s = substr(s, pos)
        best = ""
        for (name in vars)
            if (length(name) > length(best) && substr(s, 1, length(name)) == name)
                best = name
        if (best == "") {
            out = out "$"
            s = substr(s, 2)
        } else {
            out = out vars[best]
            s = substr(s, length(best) + 1)
        }
    }
    return out s
}

function replace(s, from, to,   pos, out) {
    out = ""
    while (from != "" && (pos = index(s, from)) > 0) {
        out = out substr(s, 1, pos - 1) to
        s = substr(s, pos + length(from))
    }
    return out s
}

function pretty(key,   parts, n, i, out) {
    n = split(key, parts, "+")
    out = ""
    for (i = 1; i <= n; i++)
        out = out (i > 1 ? "+" : "") (parts[i] in sym ? sym[parts[i]] : parts[i])
    return out
}

BEGIN {
    n = split("Mod4 Super Mod1 Alt Control Ctrl Mod5 AltGr slash / question ? " \
        "comma , period . minus - equal = backslash \\ grave ` less < greater > " \
        "apostrophe ' semicolon ; bracketleft [ bracketright ] Return Enter " \
        "BackSpace Backspace Escape Esc space Space", s, " ")
    for (i = 1; i < n; i += 2)
        sym[s[i]] = s[i + 1]
    home = ENVIRON["HOME"]
    count = 0
    width = 0
}

FNR == 1 { cont = ""; depth = 0 }

# Whole-line comments and blank lines are skipped
cont == "" && /^[ \t]*(#|$)/ { next }

{
    if (cont == "")
        start = FNR
    line = cont $0
    if (line ~ /\\$/) {
        cont = substr(line, 1, length(line) - 1)
        next
    }
    cont = ""
}

line ~ /^[ \t]*}[ \t]*$/ { if (depth) depth--; next }

line ~ /\{[ \t]*$/ {
    head = line
    sub(/\{[ \t]*$/, "", head)
    block[++depth] = trim(head)
    next
}

{
    # Lines inside a block are prefixed with the block header, as sway does
    full = trim(line)
    for (i = depth; i >= 1; i--)
        full = block[i] " " full

    mode = "default"
    if (full ~ /^mode[ \t]/) {
        rest = strip_flags(substr(full, 5))
        if (rest ~ /^"/) {
            rest = substr(rest, 2)
            mode = substr(rest, 1, index(rest, "\"") - 1)
            rest = substr(rest, length(mode) + 2)
        } else {
            mode = rest
            sub(/[ \t].*/, "", mode)
            rest = substr(rest, length(mode) + 1)
        }
        mode = expand(mode)
        full = trim(rest)
    }

    if (full ~ /^set[ \t]/) {
        rest = trim(substr(full, 4))
        name = rest
        sub(/[ \t].*/, "", name)
        vars[name] = expand(trim(substr(rest, length(name) + 1)))
        next
    }

    if (full !~ /^bindsym[ \t]/)
        next

    rest = strip_flags(substr(expand(full), 8))
    key = rest
    sub(/[ \t].*/, "", key)
    cmd = trim(substr(rest, length(key) + 1))

    # The description is a trailing "# ..." (a shell comment, so exec only)
    d = ""
    shown = cmd
    if (match(cmd, /[ \t]#[ \t]/)) {
        d = trim(substr(cmd, RSTART + 2))
        shown = substr(cmd, 1, RSTART - 1)
    }
    gsub(/[ \t]+/, " ", shown)
    shown = replace(trim(shown), home, "~")

    # A later bind of the same key wins, like in sway
    id = mode SUBSEP key
    if (id in seen)
        dead[seen[id]] = 1
    seen[id] = ++count

    keys[count] = (mode == "default" ? "" : "[" mode "] ") pretty(key)
    text[count] = (d != "" ? d "  ·  " : "") shown
    cmds[count] = cmd
    srcs[count] = FILENAME
    lines[count] = start
    if (length(keys[count]) > width)
        width = length(keys[count])
}

END {
    for (i = 1; i <= count; i++)
        if (!(i in dead))
            printf "%-*s  %s\x1f%s\x1f%s\x1f%d\n", width, keys[i], text[i], cmds[i], srcs[i], lines[i]
}
EOF

entries=() cmds=() srcs=() lines=()
while IFS=$'\x1f' read -r entry cmd src line; do
    entries+=("$entry")
    cmds+=("$cmd")
    srcs+=("$src")
    lines+=("$line")
done < <(gawk "$parser" "${files[@]}")

if [ "$1" = "--list" ]; then
    for i in "${!entries[@]}"; do
        printf '%s\t%s:%s\n' "${entries[i]}" "${srcs[i]}" "${lines[i]}"
    done
    exit 0
fi

idx=$(printf '%s\n' "${entries[@]}" |
    fuzzel --config "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/menu.ini" --dmenu --index --only-match --placeholder "Search bindings…" \
        --mesg="Keybindings  ·  Enter: run   Alt+e: edit" -w 110 -l 20)
rc=$?

[[ $idx =~ ^[0-9]+$ ]] || exit 0

case $rc in
    0)
        if ! out=$(swaymsg -- "${cmds[idx]}" 2>&1); then
            notify-send "Keybind help" "$out"
        fi
        ;;
    11) exec foot nvim "+${lines[idx]}" "${srcs[idx]}" ;;
esac
