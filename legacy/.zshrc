#!/usr/bin/env zsh

# GPG setup
#
export GPG_TTY="$(tty)"
if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]] || [[ -z "$SSH_AUTH_SOCK" ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    unset SSH_AGENT_PID
fi

# Theme options
#
export BAT_THEME="ansi"
export DELTA_FEATURES="+generic-dark-theme"

# Convenience aliases
#
alias :e="$EDITOR"
alias :q=exit
alias cat="$(whence -p bat) -pp"
alias ccat="$(whence -p cat)"
alias ddiff="$(whence -p diff)"
alias diff="$(whence -p delta)"
alias glow="$(whence -p glow) -s dark"
alias htop="$(whence -p btm)"
alias la="$(whence -p eza) --classify=auto --color=auto --long --all"
alias less="$(whence -p bat)"
alias ll="$(whence -p eza) --classify=auto --color=auto --long"
alias lless="$(whence -p less)"
alias lls="$(whence -p ls)"
alias ls="$(whence -p eza) --classify=auto --color=auto"
alias mmore="$(whence -p more)"
alias more="$(whence -p bat)"
alias rg="$(whence -p rg) --color=auto"
alias top="$(whence -p btm)"
alias ttop="$(whence -p top)"

if [[ -n "$(whence -p sudo 2>/dev/null)" ]]; then
    alias sudo="$(whence -p sudo) -E"

    if [[ "$OS" == "linux" ]] && [[ -x /sbin/shutdown ]]; then
        alias shutdown="$(whence -p sudo) /sbin/shutdown -h now"
    fi
fi

if [[ "$TERM" != "linux" ]]; then
    alias vi="$(whence -p hx)"
    alias vim="$(whence -p hx)"
    alias nvim="$(whence -p hx)"
fi

if [[ "$OS" == "linux" ]]; then
    if [[ -n "$DISPLAY" ]]; then
        alias pbcopy="$(whence -p xsel) --input --clipboard"
        alias pbpaste="$(whence -p xsel) --output --clipboard"
    elif [[ -n "$WAYLAND_DISPLAY" ]]; then
        alias pbcopy="$(whence -p wl-copy)"
        alias pbpaste="$(whence -p wl-paste)"
    fi
fi

# Convenience function for launching graphical apps from the terminal
#
if [[ "$OS" == "linux" ]]; then
    function xcv {
        nohup "$@" 2>/dev/null
    }
fi

# Additional Zsh behaviors
#
setopt COMBINING_CHARS
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt NO_clobber
setopt interactivecomments
setopt nonomatch
