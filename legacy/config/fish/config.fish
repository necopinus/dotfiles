#!/usr/bin/env fish

# Deal with potential PATH pollution
#
if set -q PROFILE_PATH
    fish_add_path -Pm $PROFILE_PATH
    set -e PROFILE_PATH
end

set -e MANPATH

# GPG setup
#
set -gx GPG_TTY "$(tty)"
if not set -q SSH_AUTH_SOCK;
    or not set -q gnupg_SSH_AUTH_SOCK_by;
    or test "$gnupg_SSH_AUTH_SOCK_by" -ne $fish_pid
    set -gx SSH_AUTH_SOCK "$(gpgconf --list-dirs agent-ssh-socket)"
    set -e SSH_AGENT_PID
end
gpg-connect-agent /bye &>/dev/null &
disown

# Convenience aliases
#
alias :e "$EDITOR"
alias :q exit
alias cat "$(which bat) -pp"
alias ccat "$(which cat)"
alias ddiff "$(which diff)"
alias diff "$(which delta)"
alias glow "$(which glow) -s $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json"
alias htop "$(which top)"
alias la "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long --all"
alias less "$(which bat)"
alias ll "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long"
alias lless "$(which less)"
alias lls "$(which ls)"
alias ls "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink"
alias mmore "$(which more)"
alias more "$(which bat)"
alias rg "$(which rg) --color=auto"
alias top "$(which btm)"
alias ttop "$(which top)"

if test -n "$(which sudo 2> /dev/null)"
    alias sudo "$(which sudo) -E"

    if test -x /sbin/shutdown
        alias shutdown "$(which sudo) /sbin/shutdown -h now"
    end
end

if test "$TERM" != linux
    alias vi "$(which hx)"
    alias vim "$(which hx)"
    alias nvim "$(which hx)"
end

if test "$OS" = linux
    if set -q DISPLAY
        alias pbcopy "$(which xsel) --input --clipboard"
        alias pbpaste "$(which xsel) --output --clipboard"
    else if set -q WAYLAND_DISPLAY
        alias pbcopy "$(which wl-copy)"
        alias pbpaste "$(which wl-paste)"
    end
end

# Convenience function for launching graphical apps from the terminal
#
if test "$OS" = linux
    function xcv
        nohup $argv 2>/dev/null
    end
end

# Wrap the SSH and Git CLIs in functions to ensure that the gpg-agent
# TTY is up-to-date
#
# Most tutorials will tell you to insert a `Match host * exec ...` line
# into ~/.ssh/config, but this won't properly set the TTY on some
# systems!
#
function ssh
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    set SSH_EXEC $(which ssh)
    $SSH_EXEC $argv
end

function git
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    set GIT_EXEC $(which git)
    $GIT_EXEC $argv
end

function dotfiles
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    set GIT_EXEC $(which git)
    $GIT_EXEC --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end

# Set prompt
#
if test "$TERM" != linux;
    and test -n "$(which starship 2> /dev/null)"
    starship init fish | source
end

# Hook fish postexec event to add a newline between prompts
#
#     https://stackoverflow.com/a/70644608
#
function postexec_add_newline --on-event fish_postexec
    echo ""
end

# Init zoxide; this must be done after anything that might modify fish's
# behavior
#
if test -n "$(which zoxide 2> /dev/null)"
    zoxide init fish --cmd cd | source
end

# Suppress welcome message
#
set -g fish_greeting

# Try (probably futilely) to keep environment variables in sync with the
# garbage fire that is systemd
#
if test "$OS" = linux
    $HOME/local/lib/linux/common/libexec/update-environment
end
