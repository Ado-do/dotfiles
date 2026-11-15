# shellcheck shell=bash
# Custom aliases

# replace
alias vim='vimx'
alias ls='eza --icons --group-directories-first'
alias tree='tree --dirsfirst --gitignore'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -v'
alias code='code --password-store="gnome-libsecret" --ozone-platform=wayland'
alias lvim='NVIM_APPNAME=lazyvim nvim'
alias svn='svn --config-dir "$XDG_CONFIG_HOME"/subversion' # xdg-specs

# quick commands
alias er='exec bash' # fresh shell; re-sourcing ~/.bashrc piles up PATH/hooks
alias poff='poweroff'
alias l1='ls -1'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias full='sudo tlp fullcharge'
alias lsfonts='fc-list : family | sort -u'
alias cpwd='pwd | wl-copy -n'
alias tr_enes='trans -b en:es'
alias tr_esen='trans -b es:en'
alias structurizr='podman run -it --rm -p 8080:8080 -v "${PWD}:/usr/local/structurizr:z" --userns=keep-id:uid=65532,gid=65532 structurizr/structurizr local'
alias docx2pdf='flatpak run org.libreoffice.LibreOffice --headless --convert-to pdf'
alias claude-away='systemd-inhibit --what=handle-lid-switch:sleep --who=claude --why="Remote Control" claude remote-control' # lid closed: no suspend

# quick file edits
alias bashrc='$EDITOR ~/.bashrc'
alias aliasconf='$EDITOR ~/.bashrc.d/aliases.sh'
alias envconf='$EDITOR ~/.config/shell/env.sh'
alias promptconf='$EDITOR ~/.bashrc.d/prompt.sh'

alias swayconf='$EDITOR -c "cd %:p:h" ~/.config/sway/config'
alias binds='$EDITOR ~/.config/sway/config.d/60-bindings.conf'
alias rules='$EDITOR ~/.config/sway/config.d/50-rules.conf'
alias appearance='$EDITOR ~/.config/sway/config.d/30-appearence.conf'
alias waybarconf='$EDITOR -c "cd %:p:h" ~/.config/waybar/config.jsonc'

alias footconf='$EDITOR ~/.config/foot/foot.ini'
alias vimconf='$EDITOR ~/.config/vim/vimrc'
alias nvimconf='$EDITOR ~/.config/nvim/init.lua'
alias tmuxconf='$EDITOR ~/.config/tmux/tmux.conf'

# function wrappers
webcam() {
    # Run the mpv webcam script detached from the terminal (accepts optional /dev/videoN)
    setsid -f webcam "$@" &>/dev/null
}

lvide() {
    # Run neovide with the lazyvim config, detached from the terminal (forwards any args to neovide)
    NVIM_APPNAME=lazyvim setsid -f neovide "$@" &>/dev/null
}

_open_target() {
    # Launch xdg-open through Sway; fall back to a detached xdg-open if Sway is unavailable
    local escaped
    printf -v escaped "%q" "$1"
    if ! swaymsg exec -- "xdg-open $escaped" >/dev/null 2>&1; then
        setsid -f xdg-open "$1" >/dev/null 2>&1
    fi
}

open() {
    # Loop through every argument passed to the function
    for arg in "$@"; do
        # 1. If it looks like a URI/URL (scheme:// or mailto:/tel:), open it directly
        if [[ "$arg" =~ ^([a-zA-Z0-9+.-]+://|mailto:|tel:) ]]; then
            _open_target "$arg"
            continue
        fi

        # 2. Otherwise, check if the file exists
        if [[ ! -e "$arg" ]]; then
            echo "Error: File or URI '$arg' does not exist." >&2
            continue
        fi

        _open_target "$(realpath "$arg")"
    done
}

docx2md() {
    if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: docx2md <file.docx> [...]"
        return 0
    fi
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            local out="${file%.*}.md"
            if pandoc -f docx -t gfm --wrap=none --extract-media="${file%.*}-media" "$file" -o "$out"; then
                echo "Converted '$file' -> '$out'"
            else
                echo "Error: pandoc failed on '$file'" >&2
            fi
        else
            echo "Error: File '$file' not found." >&2
        fi
    done
}

# Quick one-shot LLM query: ask-claude <question>  (piped stdin is passed as context)
# Override the model per call with ASK_MODEL=sonnet ask-claude ...
# Output is rendered with glow on a terminal, raw markdown when piped.
ask-claude() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ask-claude <question>" >&2
        return 1
    fi
    if [[ -t 1 ]] && command -v glow >/dev/null; then
        claude -p "$*" --model "${ASK_MODEL:-haiku}" --tools "" | glow --pager=false -
    else
        claude -p "$*" --model "${ASK_MODEL:-haiku}" --tools ""
    fi
}
