# shellcheck shell=bash
# lazygit: cd into the repo directory it was last in when quitting with `q`
# (like y() for yazi). Quit with `Q` to stay put.
lg() {
    local tmp cwd
    tmp="$(mktemp -t "lazygit-cwd.XXXXXX")" || return
    LAZYGIT_NEW_DIR_FILE="$tmp" command lazygit "$@"
    IFS= read -r cwd <"$tmp"
    rm -f -- "$tmp" >/dev/null
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd" || return
    fi
}
