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
