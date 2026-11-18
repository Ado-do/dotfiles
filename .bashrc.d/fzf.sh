# shellcheck shell=bash
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

    # Previews: eza/bat when installed, plain tools otherwise
    if command -v eza &>/dev/null; then
        _fzf_dir_preview='eza --tree --level=2 --color=always {}'
    else
        _fzf_dir_preview='ls -A --color=always {}'
    fi
    if command -v bat &>/dev/null; then
        _fzf_file_preview='bat -n --color=always --line-range :500 {}'
    else
        _fzf_file_preview='head -n 500 {}'
    fi

    # Ctrl-T: file contents, or a tree for directories
    export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && $_fzf_dir_preview || $_fzf_file_preview'"

    # Alt-C: directory tree preview
    export FZF_ALT_C_OPTS="--preview '$_fzf_dir_preview'"
    unset _fzf_dir_preview _fzf_file_preview

    # Ctrl-R: Ctrl-Y copies the selected command to the clipboard
    export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
fi
