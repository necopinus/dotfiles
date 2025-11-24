#!/usr/bin/env bash

set -e

OS="$(uname -s)"

# Sanity check
#
if [[ ! -f "$HOME/config/nix/flake.nix" ]]; then
    echo "This configuration must be cloned into $HOME/config/nix!"
    exit
fi

# Install (or set up) Homebrew
#
if [[ "$OS" == "Darwin" ]] && [[ -z "$(which brew 2> /dev/null)" ]]; then
	echo "Setting up Homebrew"

	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv bash)"
	elif [[ -x /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv bash)"
	else
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | env NONINTERACTIVE=1 bash

		if [[ -x /opt/homebrew/bin/brew ]]; then
			eval "$(/opt/homebrew/bin/brew shellenv bash)"
		elif [[ -x /usr/local/bin/brew ]]; then
			eval "$(/usr/local/bin/brew shellenv bash)"
		else
			echo "Cannot find Homebrew installation!"
			exit 1
		fi
	fi
fi

echo "Disabling Homebrew analytics"
brew analytics off

# Install Nix
#
if [[ -z "$(which determinate-nixd 2> /dev/null)" ]]; then
	echo "Setting up Determinate Nix"

	curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
fi
if [[ -z "$__ETC_PROFILE_NIX_SOURCED" ]]; then
	source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Build configuration
#
if [[ "$OS" == "Darwin" ]]; then
    if [[ -f /etc/pam.d/sudo_local ]]; then
        sudo mv /etc/pam.d/sudo_local /etc/pam.d/sudo_local.before-nix-darwin
    fi

    (
        cd $HOME/config/nix
        sudo nix run nix-darwin -- switch --flake .#macos
    )
else
    (
        cd $HOME/config/nix
        nix run home-manager/master -- switch --flake .#android
    )
fi
