# shellcheck shell=bash
# Shell integrations that must load at startup (key bindings / prompt hook).
# Plain tab-completions live in ~/.local/share/bash-completion/completions/
# and are loaded lazily on the first TAB.

command -v fzf &>/dev/null && \
    eval "$(fzf --bash)"
command -v zoxide &>/dev/null && \
    eval "$(zoxide init bash)"
    # eval "$(zoxide init bash --cmd cd)"
