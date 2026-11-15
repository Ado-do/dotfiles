# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Shared environment: XDG base directories, tool state relocation, PATH.
# Interactive non-login shells do not read ~/.profile, so without this they
# would fall back to ~/.bash_history, nano as $EDITOR, and unset CARGO_HOME etc.
# Sourcing is idempotent, so the double load in login shells is harmless.
if [ -f "$HOME/.config/shell/env.sh" ]; then
    . "$HOME/.config/shell/env.sh"
fi

# History
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
    unset rc
fi

# FNM with terminal hooks
# Claude Code (CLAUDECODE=1) replays a shell snapshot with a frozen PATH, so the
# per-shell multishell dir and the cd hook drift apart and fnm warns on every cd.
# There, use the stable default alias instead (fnm#1211, fnm#1366, fnm#1575).
if command -v fnm &>/dev/null; then
    if [[ -n "$CLAUDECODE" ]]; then
        export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/fnm/aliases/default/bin:$PATH"
    else
        eval "$(fnm env --use-on-cd --shell bash)"
    fi
fi
