# shellcheck shell=bash
# PROMPT_START, PROMPT_END, PROMPT_DIRECTORY and PROMPT_GIT_BRANCH are read by
# the PS1 that Fedora's bash-color-prompt builds, which shellcheck cannot see.
# shellcheck disable=SC2034
## Custom prompt

# Check if Fedora's bash-color-prompt functions are available
if declare -F prompt_setup_color_ps1 >/dev/null; then
    # RedHat format [\h@\u \W]$
    prompt_traditional_format

    # Add title to terminal (This handles the title when the terminal is IDLE)
    [ -n "$TMUX" ] && TITLE_SEQ='\[\e]0;tmux\a\]' || TITLE_SEQ='\[\e]0;\u@\h: \w\a\]'

    # tmux: green, other: blue
    [ -n "$TMUX" ] && PROMPT_COLOR='1;38;5;2' || PROMPT_COLOR='1;38;5;21'
    prompt_color "${PROMPT_COLOR}"

    # Mark start and end of prompt
    PROMPT_START="${TITLE_SEQ}\[\e[${PROMPT_COLOR}m\]["

    # Safely append Foot integration end marker (\e]133;B\e\\) inside the non-printing brackets
    # This prevents line-wrap glitches!
    PROMPT_END="\[\e[${PROMPT_COLOR}m\]]\[\e]133;B\e\\\\\]"

    # Directories view conf
    PROMPT_DIRECTORY='\w'
    PROMPT_DIRTRIM=2
    prompt_dir_color 0

    # Git branch integration
    # PS1 expands ${PROMPT_GIT_BRANCH@P} as a prompt string, which would run
    # $(...) in a branch name (git allows it). So PROMPT_GIT_BRANCH stays a
    # literal that only references variables; their values are not re-expanded.
    _update_git_prompt() {
        _git_branch=$(git branch --show-current 2>/dev/null)
        if [ -n "$_git_branch" ]; then
            # Check if there are modified files
            _git_dirty=""
            [[ -n $(git status --porcelain -uno 2>/dev/null) ]] && _git_dirty="*"
            # shellcheck disable=SC2016
            PROMPT_GIT_BRANCH='(${_git_branch}${_git_dirty})'
        else
            unset PROMPT_GIT_BRANCH
        fi
    }

    # Tell Fedora to use color 33 (yellow) for the Git branch
    prompt_git_color 33

    # This generates your standard PS1
    prompt_setup_color_ps1
else
    # Fallback prompt for other systems
    PS1="[\u@\h \W]\$ "
fi

# Ensure git prompt update hook is loaded
if [[ "$PROMPT_COMMAND" != *"_update_git_prompt"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND%;}; }_update_git_prompt"
fi
