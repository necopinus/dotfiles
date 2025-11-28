#!/usr/bin/env bash

# On Debian we need to source the default ~/.bashrc to get all of the
# capabilities we expect
#
if [[ "$FLAVOR" == "debian" ]]; then
    source /etc/skel/.bashrc
fi

# Deal with potential PATH pollution
#
if [[ -n "$PROFILE_PATH" ]]; then
    export PATH="$PROFILE_PATH:$PATH"
    unset PROFILE_PATH
fi

NEW_PATH=""
for PATH_ELEMENT in $(echo "$PATH" | tr ':' ' '); do
    if [[ ":$NEW_PATH:" != *":$PATH_ELEMENT:"* ]]; then
        if [[ -d "$PATH_ELEMENT" ]]; then
            NEW_PATH="$NEW_PATH:$PATH_ELEMENT"
        fi
    fi
done
export PATH="${NEW_PATH:1}"
unset NEW_PATH

unset MANPATH

# GPG setup
#
export GPG_TTY="$(tty)"
if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]] || [[ -z "$SSH_AUTH_SOCK" ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    unset SSH_AGENT_PID
fi

# It's most likely that we'll wind up in this shell when using a
# terminal that *only* supports dark mode (such as the Linux console or
# Android Terminal). Override a couple of configuration variables in
# in this case to make sure that things don't look eye-gougingly bad.
#
export AICHAT_LIGHT_THEME="false"
export BAT_THEME="ansi"

# Convenience aliases
#
alias :e="$EDITOR"
alias :q=exit
alias cat="$(which bat) -pp"
alias ccat="$(which cat)"
alias ddiff="$(which diff)"
alias diff="$(which delta)"
alias glow="$(which glow) -s dark"
alias htop="$(which btm)"
alias la="$(which eza) --classify=auto --color=auto --long --all"
alias less="$(which bat)"
alias ll="$(which eza) --classify=auto --color=auto --long"
alias lless="$(which less)"
alias lls="$(which ls)"
alias ls="$(which eza) --classify=auto --color=auto"
alias mmore="$(which more)"
alias more="$(which bat)"
alias rg="$(which rg) --color=auto"
alias top="$(which btm)"
alias ttop="$(which top)"

if [[ -n "$(which sudo 2>/dev/null)" ]]; then
    alias sudo="$(which sudo) -E"

    if [[ -x /sbin/shutdown ]]; then
        alias shutdown="$(which sudo) /sbin/shutdown -h now"
    fi
fi

if [[ "$TERM" != "linux" ]]; then
    alias vi="$(which hx)"
    alias vim="$(which hx)"
    alias nvim="$(which hx)"
fi

if [[ "$OS" == "linux" ]]; then
    if [[ -n "$DISPLAY" ]]; then
        alias pbcopy="$(which xsel) --input --clipboard"
        alias pbpaste="$(which xsel) --output --clipboard"
    elif [[ -n "$WAYLAND_DISPLAY" ]]; then
        alias pbcopy="$(which wl-copy)"
        alias pbpaste="$(which wl-paste)"
    fi
fi

# Convenience function for launching graphical apps from the terminal
#
if [[ "$OS" == "linux" ]]; then
    function xcv {
        nohup "$@" 2>/dev/null
    }
fi

# Wrap the SSH and Git CLIs in functions to ensure that the gpg-agent
# TTY is up-to-date
#
# Most tutorials will tell you to insert a `Match host * exec ...` line
# into ~/.ssh/config, but this won't properly set the TTY on some
# systems!
#
function ssh {
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    SSH_EXEC=$(which ssh)
    $SSH_EXEC "$@"
}

function git {
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    GIT_EXEC=$(which git)
    $GIT_EXEC "$@"
}

function dotfiles {
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    GIT_EXEC=$(which git)
    $GIT_EXEC --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

# Additional Bash behaviors
#
shopt -s histappend

# Make sure Homebrew completions are loaded
#
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    BASH_VERSION_SHORT=${BASH_VERSION%.*}
    BASH_VERSION_MAJOR=${BASH_VERSION_SHORT%.*}
    BASH_VERSION_MINOR=${BASH_VERSION_SHORT#*.}
    if [[ $BASH_VERSION_MAJOR -lt 4 ]]; then
        NO_NOSORT=1
    elif [[ $BASH_VERSION_MAJOR -eq 4 ]] && [[ $BASH_VERSION_MINOR -lt 4 ]]; then
        NO_NOSORT=1
    fi
    for COMPLETION in "$HOMEBREW_PREFIX/etc/bash_completion.d/"*; do
        if [[ -r "$COMPLETION" ]]; then
            if [[ -n "$NO_NOSORT" ]]; then
                if [[ $(grep -c nosort "$COMPLETION") -eq 0 ]]; then
                    source "$COMPLETION"
                fi
            else
                source "$COMPLETION"
            fi
        fi
    done
fi
