#!/usr/bin/env fish

# This shell is now fish
#
set -gx SHELL_NAME fish
set -gx THIS_IS_FISH 1

# Deal with potential PATH pollution
#
if set -q PROFILE_PATH
	fish_add_path -Pm $PROFILE_PATH
end
if test -d /Applications/kitty.app/Contents/Resources/man
	set -gx MANPATH :/Applications/kitty.app/Contents/Resources/man
else
	set -e MANPATH
end

# Initialize tmux, but only once
#
if status is-interactive;
and not set -q TMUX;
and test "$TERM" != "linux";
and not test -f "$HOME/_notmux";
and not test -f "$HOME/_notmux.txt";
and not test -f "$HOME/storage/shared/Documents/_notmux";
and not test -f "$HOME/storage/shared/Documents/_notmux.txt";
and test $(tmux list-sessions 2> /dev/null | grep "$(hostname -s)$(echo $DISPLAY | sed 's/:/-/'): " | grep -c "(attached)") -eq 0
	exec tmux new-session -A -s $(hostname -s)$(echo $DISPLAY | sed 's/:/-/')
else
	set -e PROFILE_PATH
end

# Kitty integration
#
# We do this here (and set 'shell_integration disabled' in kitty.conf)
# in order to apply integration in tmux
#
if test "$TERM" != "linux"
	if test "$FLAVOR" = "macos"
		set -g KITTY_INSTALLATION_DIR /Applications/kitty.app/Contents/Resources/kitty
	else if test "$FLAVOR" = "debian"
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
	set -e  SSH_AGENT_PID
end
gpg-connect-agent /bye &> /dev/null &; disown

# Convenience aliases
#
alias :e "$EDITOR"
alias :q exit
alias cat "$(which bat) -pp"
alias df "$(which duf) -theme ansi"
alias diff "$(which delta)"
alias du "$(which dust)"
alias fd "$(which fd) --color auto --hyperlink auto"
alias fzf "$(which fzf) --style=full --color=16"
alias glow "$(which glow) -s $XDG_CONFIG_HOME/glow/styles/gruvbox-material-light-hard.json"
alias grep "$(which grep) --color=auto"
alias kitten "$(which kitty) +kitten"
alias la "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long --all"
alias less "$(which bat)"
alias ll "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long"
alias lls "$(which ls)"
alias ls "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink"
alias more "$(which bat)"
alias pps "$(which ps)"
alias procs "$(which procs) --theme light"
alias ps "$(which procs) --theme light"
alias pstree "$(which procs) --theme light --tree"
alias rg "$(which rg) --color=auto"
alias sudo "$(which sudo) -E"

if test "$TERM" != "linux"
	alias nano "$(which nvim)"
	alias nvr "$(which nvr) -s"
	alias vi "$(which nvim)"
	alias vim "$(which nvim)"
	alias vimdiff "$(which nvim) -d"
end

if test "$OS" = "linux"
	if set -q DISPLAY
		alias pbcopy "$(which xsel) --input --clipboard"
		alias pbpaste "$(which xsel) --output --clipboard"
	else if set -q WAYLAND_DISPLAY
		alias pbcopy "$(which wl-copy)"
		alias pbpaste "$(which wl-paste)"
	else if test "$FLAVOR" = "termux"
		alias pbcopy "$(which termux-clipboard-set)"
		alias pbpaste "$(which termux-clipboard-get)"
	end
end

if test "$FLAVOR" = "termux"
	alias cpio "$(which busybox) cpio"
	alias hexedit "$(which busybox) hexedit"
	alias ip "$(which busybox) ip"
	alias nc "$(which busybox) nc"
	alias netcat "$(which busybox) netcat"
	alias traceroute "$(which busybox) traceroute"
	alias whois "$(which busybox) whois"
	alias xxd "$(which busybox) xxd"
end

# Convenience function for launching graphical apps from the terminal
#
if test "$OS" = "linux"
	function xcv
		nohup $argv 2> /dev/null
	end
end

# Wrap the SSH and Git CLIs in functions to ensure that the gpg-agent
# TTY is up-to-date
#
# Most tutorials will tell you to insert a `Match host * exec ...` line
# into ~/.ssh/config, but this won't properly set the TTY in Termux!
#
function ssh
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	set SSH_EXEC $(which ssh)
	$SSH_EXEC $argv
end

function git
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	set GIT_EXEC $(which git)
	$GIT_EXEC $argv
end

function dotfiles
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	set GIT_EXEC $(which git)
	$GIT_EXEC --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end

# Set prompt
#
if test "$TERM" != "linux";
and test -n "$(which starship 2> /dev/null)"
	if not test -s "$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
		mkdir -p "$XDG_CACHE_HOME/env"
		starship init $SHELL_NAME > "$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
	end

	source "$XDG_CACHE_HOME/env/starship.init.$SHELL_NAME"
end

# Init zoxide; this must be done after anything that might modify fish's
# behavior
#
if test -n "$(which zoxide 2> /dev/null)"
	if not test -s "$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
		mkdir -p "$XDG_CACHE_HOME/env"
		zoxide init --cmd cd $SHELL_NAME > "$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
	end

	source "$XDG_CACHE_HOME/env/zoxide.init.$SHELL_NAME"
end

# Yazi convenience function
#
# See: https://yazi-rs.github.io/docs/quick-start#shell-wrapper
#
function y
	set CWD_TMP $(mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$CWD_TMP"
	if read -z CWD < "$CWD_TMP"; and test -n "$CWD"; and test "$CWD" != "$PWD"
		builtin cd -- "$CWD"
	end
	rm -f -- "$CWD_TMP"
end

# Suppress welcome message
#
set -g fish_greeting

# Try (probably futilely) to keep environment variables in sync with the
# garbage fire that is systemd
#
if test "$OS" = "linux"
	$HOME/local/lib/linux/common/libexec/update-environment
end
