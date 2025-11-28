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

# Make sure that the GPG environment is set up
#
GPG_TTY=$(tty)
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY SSH_AUTH_SOCK

gpgconf --kill gpg-agent
gpg-connect-agent updatestartuptty /bye

# Set up GPG and SSH, if applicable
#
if [[ $(ls -1 $HOME/.ssh/id_* 2>/dev/null | wc -l) -eq 0 ]] &&
    [[ $(gpg --list-secret-keys --with-colons |
        grep -cE '^sec:(f|u):') -eq 0 ]]; then
    echo "Setting up initial SSH and GPG keys"

    # Create a new GPG/SSH keys
    #
    gpg --batch --expert --full-generate-key <<-EOF
	Key-Type: EDDSA
	    Key-Curve: ed25519
	    Key-Usage: sign auth
	Subkey-Type: ECDH
	    Subkey-Curve: cv25519
	    Subkey-Usage: encrypt
	Expire-Date: 4m
	Name-Real: Nathan Acks
	Name-Email: nathan.acks@cardboard-iguana.com
	EOF

    # Get the key ID of the new key
    #
    NEW_SECRET_KEY_ID="$(
        gpg --list-secret-keys --with-colons |
            grep -E '^sec:(f|u):' |
            cut -d: -f 5
    )"

    # Get the keygrip of the new key
    #
    # FIXME: I *think* that the output of --with-colons is ordered, and
    #        thus the keygrip for the primary key is just the first
    #        keygrip when this key is displayed. But I can't find any
    #        good documentation about this, so I may be wrong and this
    #        may break.
    #
    NEW_SECRET_KEY_GRIP="$(
        gpg --list-secret-keys --with-colons $NEW_SECRET_KEY_ID |
            grep -E '^grp:' |
            cut -d: -f 10 |
            head -1
    )"

    # SSH setup
    #
    gpgconf --kill gpg-agent
    rm -f "$HOME"/.gnupg/sshcontrol
    gpg-connect-agent updatestartuptty /bye &>/dev/null
    ssh-add -l &>/dev/null || true
    gpg-connect-agent "keyattr $NEW_SECRET_KEY_GRIP Use-for-ssh: true" /bye >/dev/null
    echo "$NEW_SECRET_KEY_GRIP" >>"$HOME"/.gnupg/sshcontrol

    # Update git signing key
    #
    mkdir -p $XDG_CONFIG_HOME/git
    echo "[user]" >$XDG_CONFIG_HOME/git/gpg.ini
    echo "    signingkey = $NEW_SECRET_KEY_ID" >>$XDG_CONFIG_HOME/git/gpg.ini

    # Print public GPG and SSH keys for new secret key
    #
    echo ""
    echo "-----------------------------------------"
    echo "New secret key 0x$NEW_SECRET_KEY_ID created"
    echo "-----------------------------------------"
    echo ""
    gpg --list-keys --with-keygrip --keyid-format=long $NEW_SECRET_KEY_ID
    echo "GPG public key block:"
    echo ""
    gpg --armor --export $NEW_SECRET_KEY_ID
    echo ""
    echo "SSH public key:"
    echo ""
    gpg --export-ssh-key $NEW_SECRET_KEY_ID
    echo ""
    echo "You must add the public GPG and SSH key displayed above to GitHub before"
    echo "continuing."
    echo ""
    read -rs -n 1 -p "Press any key to continue once this step is complete."
    echo ""
fi

# Try (probably futile) to guard against filesystem corruption in the
# Android Debian VM
#
sync

# A reboot is STRONGLY recommended
#
echo ""
echo "Configuration complete!"
echo ""
if [[ "$OS" == "Darwin" ]]; then
    echo "To finish setup you must reboot your system NOW."
else
    echo "To finish setup you must log out of all sessions NOW."
fi
