#!/usr/bin/env sh

# This file should ONLY be used for configuring environment variables,
# and should produce NO output!

# Source system information library
#
# Provides: OS, FLAVOR, ARCH, XDG_*_HOME, XDG_*_DIR, XDG_RUNTIME_DIR
#
source $HOME/local/lib/common/lib/system.lib.sh

# We'll need to know the shell name for some things
#
# NOTE: We cannot set this by looking at SHELL, since this variable
#       is set to the user's login shell, *not* the shell we're
#       actually running. Instead, we look for the *_VERSION
#       variable that the shells we care about set but don't export
#       to their environment. This approach means that new shells we
#       want to support have to be explicitly added to this block,
#       which is a drag. But on the other hand, this approach
#       actually *works* when using a non-default shell.
#
if [[ -n "$BASH_VERSION" ]]; then
	export SHELL_NAME="bash"
elif [[ -n "$FISH_VERSION" ]]; then
	export SHELL_NAME="fish"
elif [[ -n "$ZSH_VERSION" ]]; then
	export SHELL_NAME="zsh"
else
	export SHELL_NAME="sh"
fi

# Python warnings are annoying
#
export PYTHONWARNINGS="ignore"

# Hyperlink support in LESS
#
# You'd *think* you'd want to include --use-color here too, but
# doing so seems to disrupt *existing* colorization in applications
# like `man`
#
export LESS="-R"

# Set bat theme
#
export BAT_THEME="gruvbox-light"

# Source various API keys into the environment
#
if [[ -f "$XDG_CONFIG_HOME/api-keys.env.sh" ]]; then
	source "$XDG_CONFIG_HOME/api-keys.env.sh"
fi

# Set up Homebrew paths, etc.
#
if [[ -z "$HOMEBREW_PREFIX" ]]; then
	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv $SHELL_NAME)"
	elif [[ -x /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv $SHELL_NAME)"
	elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv $SHELL_NAME)"
	fi
fi

if [[ -d "$HOMEBREW_PREFIX/opt/curl/bin" ]]; then
	export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"
fi
if [[ -d "$HOMEBREW_PREFIX/opt/uutils-coreutils/libexec/uubin" ]]; then
	export PATH="$HOMEBREW_PREFIX/opt/uutils-coreutils/libexec/uubin:$PATH"
fi
if [[ -d "$HOMEBREW_PREFIX/opt/uutils-diffutils/libexec/uubin" ]]; then
	export PATH="$HOMEBREW_PREFIX/opt/uutils-diffutils/libexec/uubin:$PATH"
fi
if [[ -d "$HOMEBREW_PREFIX/opt/uutils-findutils/libexec/uubin" ]]; then
	export PATH="$HOMEBREW_PREFIX/opt/uutils-findutils/libexec/uubin:$PATH"
fi

# Set up Nix, if applicable
#
# Note that we have to force nix-daemon.sh to be re-sourced here in
# order to ensure that these directories show up early in our final
# PATH; this is also why this operation has to happen *after* Homebrew
# is set up, but *before* mise-en-place is initialized
#
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
	unset __ETC_PROFILE_NIX_SOURCED
	source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Set up mise-en-place, if applicable
#
# The weird which AND -x test is to work around the fact that this
# file may be sourced by either Zsh or Bash/sh, which handle 'which'
# in slightly different ways
#
if [[ -x "$(which mise 2> /dev/null)" ]]; then
	eval "$(mise activate $SHELL_NAME)"
	eval "$(mise env)"
fi

# Add ~/bin and ~/local/bin to the PATH (the second of these is
# duplicative, but necessary to pick up any locally-installed man
# pages)
#
export PATH="$HOME/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Add system- and architecture-specific bin directories to PATH;
# done last so that we can override/wrap previous commands if needed
#
if [[ -d $HOME/local/lib/common/bin ]]; then
	export PATH="$HOME/local/lib/common/bin:$PATH"
fi
if [[ -d $HOME/local/lib/$OS/common/bin ]]; then
	export PATH="$HOME/local/lib/$OS/common/bin:$PATH"
fi
if [[ -d $HOME/local/lib/$OS/$FLAVOR/common/bin ]]; then
	export PATH="$HOME/local/lib/$OS/$FLAVOR/common/bin:$PATH"
fi
if [[ -d $HOME/local/lib/$OS/$FLAVOR/$ARCH/bin ]]; then
	export PATH="$HOME/local/lib/$OS/$FLAVOR/$ARCH/bin:$PATH"
fi

# Set LS_COLORS, as a surprising number of applications look wonky is
# this variable isn't available
#
# The weird which AND -x test is to work around the fact that this
# file may be sourced by either Zsh or Bash/sh, which handle 'which'
# in slightly different ways
#
if [[ -x "$(which dircolors 2> /dev/null)" ]]; then
	eval "$(dircolors)"
fi

# Set EDITOR; we do this late to ensure that our full path is
# available
#
if [[ "$TERM" != "linux" ]]; then
	export EDITOR="$(which hx)"
else
	export EDITOR="$(which nano)"
fi

export VISUAL="$EDITOR"

# Later parts of the initialization process can append a lot of junk
# to the PATH that we don't necessarily want; if this is a "fresh"
# PATH, save it off so that we can deal with this issue in .zshrc.local
#
if [[ -z "$PROFILE_PATH" ]]; then
	export PROFILE_PATH="$PATH"
fi

# Make sure that the SHELL_NAME variable isn't carried over
#
unset SHELL_NAME
