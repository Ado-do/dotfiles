# fzf configuration (key bindings are loaded in bash_completion.sh)

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'

    # Use fd for file/dir listing (respects .gitignore)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

        # ** completion
        _fzf_compgen_path() { fd --hidden --follow --exclude .git . "$1"; }
        _fzf_compgen_dir() { fd --type d --hidden --follow --exclude .git . "$1"; }
    fi

    # Ctrl-T: bat for files, eza tree for directories
    export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && eza --tree --level=2 --color=always {} || bat -n --color=always --line-range :500 {}'"

    # Alt-C: directory tree preview
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

    # Ctrl-R: Ctrl-Y copies the selected command to the clipboard
    export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
fi
