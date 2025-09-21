#!/usr/bin/env bash

# For some reason Termux's Bash reads ~/.profile AFTER ~/.bashrc (?!?!)
#
source $HOME/.profile

# Termux always starts Bash, so we need to exec fish here
#
if [[ "$FLAVOR" == "termux" ]] \
&& [[ -z "$THIS_IS_FISH" ]] \
&& [[ $- =~ i ]] \
&& [[ ! -f "$HOME/_nofish" ]] \
&& [[ ! -f "$HOME/_nofish.txt" ]] \
&& [[ ! -f "$HOME/storage/shared/Documents/_nofish" ]] \
&& [[ ! -f "$HOME/storage/shared/Documents/_nofish.txt" ]]; then
	exec $HOME/bin/fish -li
fi

# On Debian we need to source the default ~/.bashrc to get all of the
# capabilities we expect
#
if [[ "$FLAVOR" == "debian" ]]; then
	source /etc/skel/.bashrc
fi

# Deal with potential PATH pollution
#
if [[ -n "$PROFILE_PATH" ]]; then
	NEW_PATH=""
	for PATH_ELEMENT in $(echo "$PROFILE_PATH:$PATH" | tr ':' ' '); do
		if [[ ":$NEW_PATH:" != *":$PATH_ELEMENT:"* ]]; then
			NEW_PATH="$NEW_PATH:$PATH_ELEMENT"
		fi
	done
	export PATH="${NEW_PATH:1}"
	unset NEW_PATH PROFILE_PATH
fi

if [[ -d "/Applications/kitty.app/Contents/Resources/man" ]]; then
	export MANPATH=":/Applications/kitty.app/Contents/Resources/man"
else
	unset MANPATH
fi

# Kitty integration
#
if [[ "$TERM" != "linux" ]]; then
	if [[ -d "$HOME/local/lib/kitty.app/lib/kitty" ]]; then
		export KITTY_INSTALLATION_DIR="$HOME/local/lib/kitty.app/lib/kitty"
	elif [[ "$FLAVOR" == "macos" ]]; then
		export KITTY_INSTALLATION_DIR="/Applications/kitty.app/Contents/Resources/kitty"
	elif [[ "$FLAVOR" == "termux" ]]; then
		export KITTY_INSTALLATION_DIR="$PREFIX/lib/kitty"
	elif [[ "$OS" == "linux" ]]; then
		export KITTY_INSTALLATION_DIR="/usr/lib/kitty"
	fi

	if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
		export KITTY_SHELL_INTEGRATION="enabled"
		source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
	fi
fi

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
export NVIM_PLAIN_DARK_THEME="true"

# Convenience aliases
#
alias :e="$EDITOR"
alias :q=exit
alias cat="$(which bat) -pp"
alias ccat="$(which cat)"
alias ddf="$(which df)"
alias ddiff="$(which diff)"
alias ddu="$(which du)"
alias df="$(which duf) -theme ansi"
alias diff="$(which delta)"
alias du="$(which dust)"
alias fd="$(which fd) --color auto"
alias ffind="$(which find)"
alias find="$(which fd) --color auto"
alias fzf="$(which fzf) --style=full --color=16"
alias glow="$(which glow) -s dark"
alias grep="$(which rg) --color=auto"
alias ggrep="$(which grep) --color=auto"
alias la="$(which eza) --classify=auto --color=auto --long --all"
alias less="$(which bat)"
alias ll="$(which eza) --classify=auto --color=auto --long"
alias lless="$(which less)"
alias lls="$(which ls)"
alias ls="$(which eza) --classify=auto --color=auto"
alias mmore="$(which more)"
alias more="$(which bat)"
alias pps="$(which ps)"
alias ppstree="$(which pstree)"
alias procs="$(which procs) --theme dark"
alias ps="$(which procs) --theme dark"
alias pstree="$(which procs) --theme dark --tree"
alias rg="$(which rg) --color=auto"
alias shutdown="sudo $(which shutdown) -h now"

if [[ -n "$(which sudo 2> /dev/null)" ]]; then
	alias sudo="$(which sudo) -E"
fi

if [[ "$TERM" != "linux" ]]; then
	alias nano="$(which nvim)"
	alias nvr="$(which nvr) -s"
	alias vi="$(which nvim)"
	alias vim="$(which nvim)"
	alias vimdiff="$(which nvim) -d"
fi

if [[ "$OS" == "linux" ]]; then
	if [[ -n "$DISPLAY" ]]; then
		alias pbcopy="$(which xsel) --input --clipboard"
		alias pbpaste="$(which xsel) --output --clipboard"
	elif [[ -n "$WAYLAND_DISPLAY" ]]; then
		alias pbcopy="$(which wl-copy)"
		alias pbpaste="$(which wl-paste)"
	elif [[ "$FLAVOR" == "termux" ]]; then
		alias pbcopy="$(which termux-clipboard-set)"
		alias pbpaste="$(which termux-clipboard-get)"
	fi
fi

if [[ "$FLAVOR" == "termux" ]]; then
	alias cpio="$(which busybox) cpio"
	alias hexedit="$(which busybox) hexedit"
	alias ip="$(which busybox) ip"
	alias nc="$(which busybox) nc"
	alias netcat="$(which busybox) netcat"
	alias traceroute="$(which busybox) traceroute"
	alias whois="$(which busybox) whois"
	alias xxd="$(which busybox) xxd"
fi

# Convenience function for launching graphical apps from the terminal
#
if [[ "$OS" == "linux" ]]; then
	function xcv {
		nohup "$@" 2> /dev/null
	}
fi

# Wrap the SSH and Git CLIs in functions to ensure that the gpg-agent
# TTY is up-to-date
#
# Most tutorials will tell you to insert a `Match host * exec ...` line
# into ~/.ssh/config, but this won't properly set the TTY in Termux!
#
function ssh {
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	SSH_EXEC=$(which ssh)
	$SSH_EXEC "$@"
}

function git {
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	GIT_EXEC=$(which git)
	$GIT_EXEC "$@"
}

function dotfiles {
	gpg-connect-agent updatestartuptty /bye &> /dev/null
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
