# shellcheck shell=bash
# The quotes below hold terminal escape sequences (\e]133;...), not quoting
# mistakes, so silence the SC1003 "escape a single quote" notes.
# shellcheck disable=SC1003
# foot integrations

# Marks start of output
[[ "$PS0" != *"\e]133;C\e\\"* ]] && PS0+='\e]133;C\e\\' || true

# Prompt scrolling markers
prompt_marker() {
    printf '\e]133;A\e\\'
    #printf '\e]133;C\e\\\e]133;A\e\\'
}
command_done() {
    printf '\e]133;D\e\\'
}

# New terminal in CWD
osc7_cwd() {
    local encoded
    local strlen=${#PWD}
    local pos c o
    for ((pos = 0; pos < strlen; pos++)); do
        c=${PWD:$pos:1}
        case "$c" in
            [-/:_.!\'\(\)~[:alnum:]]) o="${c}" ;;
            *) printf -v o '%%%02X' "'${c}" ;;
        esac
        encoded+="${o}"
    done
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}

foot_integration() {
    command_done
    prompt_marker
    osc7_cwd
}

if [[ "$PROMPT_COMMAND" != *"foot_integration"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND%;}; }foot_integration"
fi

# Scrollback output instead of clear it when CTRL-L
clear-screen-keep-sb() {
    printf '\e[%dS' $((${LINES:-24} - 1))
    tput -x clear
}
[[ $- == *i* ]] && bind -x '"\C-l":"clear-screen-keep-sb"' || true
