#!/usr/bin/env sh

# This file should ONLY be used for configuring environment variables,
# and should produce NO output!

# Source system information library
#
# Provides: OS, FLAVOR, ARCH, XDG_*_HOME, XDG_*_DIR, XDG_RUNTIME_DIR
#
source $HOME/local/lib/common/lib/system.lib.sh

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

# Set LS_COLORS, as a surprising number of applications look wonky is
# this variable isn't available
#
# The weird which AND -x test is to work around the fact that this
# file may be sourced by either Zsh or Bash/sh, which handle 'which'
# in slightly different ways
#
if [[ -x "$(which dircolors 2>/dev/null)" ]]; then
    eval "$(dircolors)"
fi
