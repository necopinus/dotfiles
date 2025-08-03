#!/usr/bin/env zsh

# Deal with potential PATH pollution
#
typeset -U path PATH
if [[ -n "$PROFILE_PATH" ]]; then
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

		autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
		kitty-integration; unfunction kitty-integration
	fi
fi

# GPG setup
#
export GPG_TTY="$(tty)"
if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]] || [[ -z "$SSH_AUTH_SOCK" ]]; then
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	unset SSH_AGENT_PID
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

# Make sure Homebrew completions are loaded
#
if [[ -n "$HOMEBREW_PREFIX" ]]; then
	FPATH=$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH
	autoload -Uz compinit
	compinit
fi
