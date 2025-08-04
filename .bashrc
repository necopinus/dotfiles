#!/usr/bin/env bash

# Termux always starts Bash, so we need to exec fish here
#
if [[ "$FLAVOR" == "termux" ]] \
&& [[ -z "$THIS_IS_FISH" ]] \
&& [[ $- =~ i ]] \
&& [[ ! -f "$HOME/_nofish" ]]
&& [[ ! -f "$HOME/_nofish.txt" ]]
&& [[ ! -f "$HOME/storage/shared/Documents/_nofish" ]]
&& [[ ! -f "$HOME/storage/shared/Documents/_nofish.txt" ]]; then
	exec $HOME/bin/fish -li
fi

# Deal with potential PATH pollution
#
if [[ -n "$PROFILE_PATH" ]] && [[ ! ":$PATH:" =~ :$PROFILE_PATH:* ]]; then
	export PATH="$PROFILE_PATH:$PATH"
fi
unset PROFILE_PATH

if [[ -d "/Applications/kitty.app/Contents/Resources/man" ]]; then
	export MANPATH=":/Applications/kitty.app/Contents/Resources/man"
else
	unset MANPATH
fi

# Kitty integration
#
if [[ "$TERM" != "linux" ]]; then
	if [[ "$FLAVOR" == "macos" ]]; then
		export KITTY_INSTALLATION_DIR="/Applications/kitty.app/Contents/Resources/kitty"
	elif [[ "$FLAVOR" == "debian" ]]; then
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
