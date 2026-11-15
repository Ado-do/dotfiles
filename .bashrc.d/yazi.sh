# shellcheck shell=bash
function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    rm -f -- "$tmp" >/dev/null
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd" || return
    fi
}
