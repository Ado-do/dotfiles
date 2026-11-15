# ~/.config/shell/env.sh
#
# Single source of truth for this account's environment.
#
# Sourced by:
#   ~/.profile   (login shells — also pulled in by ~/.config/sway/environment)
#   ~/.bashrc     (interactive non-login shells, so they behave like logins)
#
# A login shell sources this twice (profile -> bashrc), and nested interactive
# shells source it again, so everything here MUST stay idempotent and POSIX sh
# compatible (it is also read by whichever shell sway uses).
#
# The systemd user session does not read this file — it reads the literal
# values in ~/.config/environment.d/10-xdg.conf. Keep the two in sync.
#
# Intentional differences (not mirrored in environment.d):
#   HISTFILE, PYTHON_HISTORY   interactive-shell state, useless to services
#   XDG_PICTURES_DIR           also defined in ~/.config/user-dirs.dirs
#   PATH additions             mirrored there, but only the static directories
#                              (no fnm multishell dir, no existence checks)

# --- XDG base directories -------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_SCREENSHOTS_DIR="$XDG_PICTURES_DIR/Screenshots"

# --- Preferred programs ---------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='firefox'
export QT_QPA_PLATFORMTHEME='gtk3'

# --- Keep tool state out of $HOME ----------------------------------------
export HISTFILE="$XDG_STATE_HOME/bash/history"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export GOPATH="$XDG_DATA_HOME/go"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
export CODEX_HOME="$XDG_CONFIG_HOME/codex"
export COPILOT_HOME="$XDG_CONFIG_HOME/copilot"
#export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# --- SSH agent --------------------------------------------------------------
# OpenSSH's socket-activated agent (systemctl --user enable ssh-agent.socket).
# Only set when unset, so a forwarded agent (ssh -A) is not overridden.
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"
fi

# NOTE: GRIMSHOT_FILENAME_FORMAT was removed here. grimshot uses that variable
# as a *literal* filename (no date expansion), so exporting a timestamped value
# made every screenshot in a session overwrite the same file. Screenshots are
# taken by ~/.config/sway/scripts/screenshot.sh, which stamps the name itself.

# --- Homebrew (system-wide install) ---------------------------------------
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

# Guarded so repeated sourcing cannot grow INFOPATH without bound, and written
# without a trailing colon (an empty path element would mean "here").
case ":$INFOPATH:" in
    *":/home/linuxbrew/.linuxbrew/share/info:"*) ;;
    *)
        if [ -n "$INFOPATH" ]; then
            export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"
        else
            export INFOPATH="/home/linuxbrew/.linuxbrew/share/info"
        fi
        ;;
esac

# --- PATH -----------------------------------------------------------------
# Prepend a directory only if it exists and is not already on PATH.
add_to_path() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

add_to_path "$CARGO_HOME/bin"
add_to_path "$GOPATH/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.opencode/bin"
add_to_path "$HOMEBREW_PREFIX/bin"
add_to_path "$HOMEBREW_PREFIX/sbin"
add_to_path "$HOME/.local/share/JetBrains/Toolbox/scripts"
add_to_path "$XDG_DATA_HOME/fnm"
add_to_path "$PNPM_HOME/bin"
export PATH

unset -f add_to_path
