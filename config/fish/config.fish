#!/usr/bin/env fish

# This shell is now fish
#
set -gx SHELL_NAME fish
set -gx THIS_IS_FISH 1

# Deal with potential PATH pollution
#
if set -q PROFILE_PATH
    fish_add_path -Pm $PROFILE_PATH
    set -e PROFILE_PATH
end

if test -d $HOME/local/lib/kitty.app/share/man
    set -gx MANPATH :$HOME/local/lib/kitty.app/share/man
else if test -d /Applications/kitty.app/Contents/Resources/man
    set -gx MANPATH :/Applications/kitty.app/Contents/Resources/man
else
    set -e MANPATH
end

# Kitty integration
#
# We do this here (and set 'shell_integration disabled' in kitty.conf)
# so that things still work if we're using a terminal multiplexer like
# tmux
#
if test "$TERM" != linux
    if test -d $HOME/local/lib/kitty.app/lib/kitty
        set -g KITTY_INSTALLATION_DIR $HOME/local/lib/kitty.app/lib/kitty
    else if test "$FLAVOR" = macos
        set -g KITTY_INSTALLATION_DIR /Applications/kitty.app/Contents/Resources/kitty
    else if test "$OS" = linux
        set -g KITTY_INSTALLATION_DIR /usr/lib/kitty
    end

    if set -q KITTY_INSTALLATION_DIR
        set -g KITTY_SHELL_INTEGRATION enabled

        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set -p fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
    end
end

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
alias ddf "$(which df)"
alias ddiff "$(which diff)"
alias ddu "$(which du)"
alias df "$(which duf) -theme ansi"
alias diff "$(which delta)"
alias du "$(which dust)"
alias fd "$(which fd) --color auto --hyperlink"
alias ffind "$(which find)"
alias find "$(which fd) --color auto --hyperlink"
alias fzf "$(which fzf) --style=full --color=16"
alias glow "$(which glow) -s $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json"
alias grep "$(which rg) --color=auto"
alias ggrep "$(which grep) --color=auto"
alias htop "$(which top)"
alias la "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long --all"
alias less "$(which bat)"
alias ll "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long"
alias lless "$(which less)"
alias lls "$(which ls)"
alias ls "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink"
alias mmore "$(which more)"
alias more "$(which bat)"
alias pps "$(which ps)"
alias ppstree "$(which pstree)"
alias procs "$(which procs) --theme light"
alias ps "$(which procs) --theme light"
alias pstree "$(which procs) --theme light --tree"
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
    if not test -s "$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
        mkdir -p "$XDG_CACHE_HOME/env"
        starship init $SHELL_NAME >"$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
    end

    source "$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
end

# Init zoxide; this must be done after anything that might modify fish's
# behavior
#
if test -n "$(which zoxide 2> /dev/null)"
    if not test -s "$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
        mkdir -p "$XDG_CACHE_HOME/env"
        zoxide init --cmd cd $SHELL_NAME >"$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
    end

    source "$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
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
