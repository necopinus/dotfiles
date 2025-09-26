#!/usr/bin/env zsh

# Deal with potential PATH pollution
#
typeset -U path PATH
if [[ -n "$PROFILE_PATH" ]]; then
	export PATH="$PROFILE_PATH:$PATH"
	unset PROFILE_PATH
fi

if [[ -d "$HOME/local/lib/kitty.app/share/man" ]]; then
	export MANPATH=":$HOME/local/lib/kitty.app/share/man"
elif [[ -d "/Applications/kitty.app/Contents/Resources/man" ]]; then
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
	elif [[ "$OS" == "linux" ]]; then
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
alias cat="$(whence -p bat) -pp"
alias ccat="$(whence -p cat)"
alias ddf="$(whence -p df)"
alias ddiff="$(whence -p diff)"
alias ddu="$(whence -p du)"
alias df="$(whence -p duf) -theme ansi"
alias diff="$(whence -p delta)"
alias du="$(whence -p dust)"
alias fd="$(whence -p fd) --color auto"
alias ffind="$(whence -p find)"
alias find="$(whence -p fd) --color auto"
alias fzf="$(whence -p fzf) --style=full --color=16"
alias glow="$(whence -p glow) -s dark"
alias grep="$(whence -p rg) --color=auto"
alias ggrep="$(whence -p grep) --color=auto"
alias htop="$(whence -p btm)"
alias la="$(whence -p eza) --classify=auto --color=auto --long --all"
alias less="$(whence -p bat)"
alias ll="$(whence -p eza) --classify=auto --color=auto --long"
alias lless="$(whence -p less)"
alias lls="$(whence -p ls)"
alias ls="$(whence -p eza) --classify=auto --color=auto"
alias mmore="$(whence -p more)"
alias more="$(whence -p bat)"
alias pps="$(whence -p ps)"
alias ppstree="$(whence -p pstree)"
alias procs="$(whence -p procs) --theme dark"
alias ps="$(whence -p procs) --theme dark"
alias pstree="$(whence -p procs) --theme dark --tree"
alias rg="$(whence -p rg) --color=auto"
alias top="$(whence -p btm)"
alias ttop="$(whence -p top)"

if [[ -n "$(whence -p sudo 2> /dev/null)" ]]; then
	alias sudo="$(whence -p sudo) -E"

	if [[ -x /sbin/shutdown ]]; then
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
		nohup "$@" 2> /dev/null
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
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	SSH_EXEC=$(whence -p ssh)
	$SSH_EXEC "$@"
}

function git {
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	GIT_EXEC=$(whence -p git)
	$GIT_EXEC "$@"
}

function dotfiles {
	gpg-connect-agent updatestartuptty /bye &> /dev/null
	GIT_EXEC=$(whence -p git)
	$GIT_EXEC --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"
}

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
