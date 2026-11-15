# Bat integrations and configuration

if command -v bat &>/dev/null; then
    # Replace cat with bat
    alias cat='bat'

    # Use bat as the manual pager for syntax-highlighted man pages
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"

    # Colorized --help helper function
    bathelp() {
        "$@" --help 2>&1 | bat --plain --language=help
    }
fi
