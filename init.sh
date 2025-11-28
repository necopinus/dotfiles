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
if [[ "$OS" == "Darwin" ]] && [[ -z "$(which brew 2>/dev/null)" ]]; then
    echo "Setting up Homebrew"

    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv bash)"
    else
        xcode-select --install || true
        until $(xcode-select --print-path &>/dev/null); do
            sleep 4
        done

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

# Make sure that a few required (or just nice-to-have) Debian packages
# are installed
#
if [[ "$OS" == "Linux" ]]; then
    sudo apt update
    sudo apt install -y curl dialog man-db
fi

# Install Nix
#
if [[ -z "$(which determinate-nixd 2>/dev/null)" ]]; then
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

# Install desktop on Debian VM
#
if [[ "$OS" == "Linux" ]]; then
    sudo apt install -y tigervnc-standalone-server xfce4 yubikey-manager-qt
fi

# Fix permissions; probably not necessary anymore
#
chmod 700 $HOME/.ssh
find $HOME/.ssh -type d -exec chmod 700 "{}" \;
find $HOME/.ssh -type f -exec chmod 600 "{}" \;

chmod 700 $HOME/.gnupg
find $HOME/.gnupg -type d -exec chmod 700 "{}" \;
find $HOME/.gnupg -type f -exec chmod 600 "{}" \;
