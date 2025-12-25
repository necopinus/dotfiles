#!/usr/bin/env bash

set -e

# Set OS type
#
OS="$(uname -s)"

# Sanity check
#
if [[ ! -f "$HOME/config/nix/flake.nix" ]]; then
    echo "This configuration must be cloned into $HOME/config/nix!"
    exit
fi

# Install (or set up) Homebrew
#
if [[ "$OS" == "Darwin" ]]; then
    if [[ ! -x /opt/homebrew/bin/brew ]] && [[ ! -x /usr/local/bin/brew ]]; then
        xcode-select --install || true
        until xcode-select --print-path &>/dev/null; do
            sleep 4
        done

        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | env NONINTERACTIVE=1 bash
    fi
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv bash)"
    else
        echo "Cannot find Homebrew installation!"
        exit 1
    fi
fi

# Make sure that required packages are installed
#
if [[ "$OS" == "Linux" ]]; then
    sudo apt install -y curl dconf-service dialog man-db
fi

# Install Nix
#
if [[ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
fi
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [[ $(grep -c "^trusted-users = " /etc/nix/nix.custom.conf) -eq 0 ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        echo "trusted-users = root @admin" | sudo tee -a /etc/nix/nix.custom.conf
        sudo launchctl kickstart -k system/systems.determinate.nix-daemon
    else
        echo "trusted-users = root @sudo" | sudo tee -a /etc/nix/nix.custom.conf
        sudo systemctl restart nix-daemon.service
    fi
fi

# Clear out macOS settings that need to be set (or not set) explicitly
#
if [[ "$OS" == "Darwin" ]]; then
    defaults delete com.apple.TextEdit AlwaysLightBackground 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleAccentColor 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleHighlightColor 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleIconAppearanceTintColor 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleInterfaceStyle 2>/dev/null || true
fi

# Move files that we might overwrite out of the way
#
if [[ "$OS" == "Darwin" ]]; then
    if [[ -e /etc/bashrc ]] && [[ ! -L /etc/bashrc ]]; then
        sudo mv /etc/bashrc /etc/bashrc.before-nix
    fi
    if [[ -e /etc/pam.d/sudo_local ]] && [[ ! -L /etc/pam.d/sudo_local ]]; then
        sudo mv /etc/pam.d/sudo_local /etc/pam.d/sudo_local.before-nix
    fi
    if [[ -e /etc/zprofile ]] && [[ ! -L /etc/zprofile ]]; then
        sudo mv /etc/zprofile /etc/zprofile.before-nix
    fi
    if [[ -e /etc/zshenv ]] && [[ ! -L /etc/zshenv ]]; then
        sudo mv /etc/zshenv /etc/zshenv.before-nix
    fi
    if [[ -e /etc/zshrc ]] && [[ ! -L /etc/zshrc ]]; then
        sudo mv /etc/zshrc /etc/zshrc.before-nix
    fi
fi
if [[ -e "$HOME"/.bashrc ]] && [[ ! -L "$HOME"/.bashrc ]]; then
    mv "$HOME"/.bashrc "$HOME"/.bashrc.before-nix
fi
if [[ -e "$HOME"/.profile ]] && [[ ! -L "$HOME"/.profile ]]; then
    mv "$HOME"/.profile "$HOME"/.profile.before-nix
fi

# Build configuration
#
if [[ "$OS" == "Darwin" ]]; then
    (
        cd "$HOME/config/nix"
        sudo -H nix run nix-darwin -- switch --flake .#macos
    )
else
    (
        cd "$HOME/config/nix"
        dbus-run-session nix run home-manager/master -- switch --flake .#android
    )
fi

# Install desktop on Debian VM
#
if [[ "$OS" == "Linux" ]]; then
    sudo apt install -y \
        bubblewrap \
        build-essential \
        fuse3 \
        libseccomp-dev \
        procps \
        rtkit \
        seatd \
        strace \
        yubikey-manager-qt

    # Make sure GPG is removed so as not to interfere with the version
    # from Nixpkgs
    #
    sudo apt purge -y --autoremove --purge gnupg

    # Comment out global SSH option that Nix's ssh binary doesn't like
    #
    sudo sed -i 's/^    GSSAPIAuthentication yes/#   GSSAPIAuthentication yes/' /etc/ssh/ssh_config

    # Sync timezone with Android
    #
    sudo ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime

    # We need to tweak a few things in order to manage our own graphical
    # shell
    #
    sudo usermod -a -G render "$USER"
    sudo mv /etc/profile.d/activate_display.sh /etc/profile.d/activate_display.sh.disabled
    rm -f "$HOME"/weston.env
fi

# Update runtime environment
#
unset __ETC_PROFILE_NIX_SOURCED
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
if [[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]]; then
    source "$XDG_CONFIG_HOME/user-dirs.dirs"
fi

# Run GPU setup for nixpkgs/home-manager
#
if [[ "$OS" == "Linux" ]]; then
    sudo "$(which non-nixos-gpu-setup)"
fi

# Set up directories and symlinks
#
mkdir -p "$XDG_CACHE_HOME"
if [[ -d "$HOME"/.cache ]] && [[ ! -L "$HOME"/.cache ]]; then
    cp -an "$HOME"/.cache/* "$XDG_CACHE_HOME"/ || true
    rm -rf "$HOME"/.cache
fi
if [[ ! -e "$HOME"/.cache ]]; then
    ln -sfT "$XDG_CACHE_HOME" "$HOME"/.cache
fi

mkdir -p "$XDG_CONFIG_HOME"
if [[ -d "$HOME"/.config ]] && [[ ! -L "$HOME"/.config ]]; then
    cp -an "$HOME"/.config/* "$XDG_CONFIG_HOME"/ || true
    rm -rf "$HOME"/.config
fi
if [[ ! -e "$HOME"/.config ]]; then
    ln -sfT "$XDG_CONFIG_HOME" "$HOME"/.config
fi

mkdir -p "$HOME"/local
if [[ -d "$HOME"/.local ]] && [[ ! -L "$HOME"/.local ]]; then
    cp -an "$HOME"/.local/* "$HOME"/local/ || true
    rm -rf "$HOME"/.local
fi
if [[ ! -e "$HOME"/.local ]]; then
    # We need to use the system `ln` here, as Nix's `ln` will be
    # (temporarily) broken
    #
    /usr/bin/ln -sfT "$HOME"/local "$HOME"/.local
fi
/usr/bin/ln -sfT "$XDG_STATE_HOME"/nix/profiles/profile "$HOME"/.nix-profile
if [[ ! -e "$HOME"/.var ]]; then
    ln -sfT "$HOME"/local "$HOME"/.var
fi

# Set up XDG user directories
#
mkdir -p "$XDG_DOCUMENTS_DIR"
if [[ -d "$HOME/Documents" ]] &&
    [[ "$XDG_DOCUMENTS_DIR" != "$HOME/Documents" ]]; then
    cp -an "$HOME/Documents"/* "$XDG_DOCUMENTS_DIR"/ || true
    rm -rf "$HOME/Documents"
fi
if [[ -d "$HOME/data/documents" ]] &&
    [[ "$XDG_DOCUMENTS_DIR" != "$HOME/data/documents" ]]; then
    cp -an "$HOME/data/documents"/* "$XDG_DOCUMENTS_DIR"/ || true
    rm -rf "$HOME/data/documents"
fi
if [[ "$XDG_DOCUMENTS_DIR" == /mnt/shared/Documents ]]; then
    mkdir -p "$HOME/data"
    ln -sfT /mnt/shared/Documents "$HOME/data/documents"
fi

mkdir -p "$XDG_DESKTOP_DIR"
if [[ -d "$HOME/Desktop" ]] &&
    [[ "$XDG_DESKTOP_DIR" != "$HOME/Desktop" ]]; then
    cp -an "$HOME/Desktop"/* "$XDG_DESKTOP_DIR"/ || true
    rm -rf "$HOME/Desktop"
fi

mkdir -p "$XDG_DOWNLOAD_DIR"
if [[ -d "$HOME/Downloads" ]] &&
    [[ "$XDG_DOWNLOAD_DIR" != "$HOME/Downloads" ]]; then
    cp -an "$HOME/Downloads"/* "$XDG_DOWNLOAD_DIR"/ || true
    rm -rf "$HOME/Downloads"
fi
if [[ -d "$HOME/Download" ]] &&
    [[ "$XDG_DOWNLOAD_DIR" != "$HOME/Download" ]]; then
    cp -an "$HOME/Download"/* "$XDG_DOWNLOAD_DIR"/ || true
    rm -rf "$HOME/Download"
fi
if [[ -d "$HOME/downloads" ]] &&
    [[ "$XDG_DOWNLOAD_DIR" != "$HOME/downloads" ]]; then
    cp -an "$HOME/downloads"/* "$XDG_DOWNLOAD_DIR"/ || true
    rm -rf "$HOME/downloads"
fi
if [[ -d "$HOME/data/downloads" ]] &&
    [[ "$XDG_DOWNLOAD_DIR" != "$HOME/data/downloads" ]]; then
    cp -an "$HOME/data/downloads"/* "$XDG_DOWNLOAD_DIR"/ || true
    rm -rf "$HOME/data/downloads"
fi
if [[ "$XDG_DOWNLOAD_DIR" == /mnt/shared/Download ]]; then
    mkdir -p "$HOME/data"
    ln -sfT /mnt/shared/Download "$HOME/downloads"
fi

mkdir -p "$XDG_MUSIC_DIR"
if [[ -d "$HOME/Music" ]] &&
    [[ "$XDG_MUSIC_DIR" != "$HOME/Music" ]]; then
    cp -an "$HOME/Music"/* "$XDG_MUSIC_DIR"/ || true
    rm -rf "$HOME/Music"
fi
if [[ -d "$HOME/data/music" ]] &&
    [[ "$XDG_MUSIC_DIR" != "$HOME/data/music" ]]; then
    cp -an "$HOME/data/music"/* "$XDG_MUSIC_DIR"/ || true
    rm -rf "$HOME/data/music"
fi
if [[ "$XDG_MUSIC_DIR" == /mnt/shared/Music ]]; then
    mkdir -p "$HOME/data"
    ln -sfT /mnt/shared/Music "$HOME/data/music"
fi

mkdir -p "$XDG_PICTURES_DIR"
if [[ -d "$HOME/Pictures" ]] &&
    [[ "$XDG_PICTURES_DIR" != "$HOME/Pictures" ]]; then
    cp -an "$HOME/Pictures"/* "$XDG_PICTURES_DIR"/ || true
    rm -rf "$HOME/Pictures"
fi
if [[ -d "$HOME/data/pictures" ]] &&
    [[ "$XDG_PICTURES_DIR" != "$HOME/data/pictures" ]]; then
    cp -an "$HOME/data/pictures"/* "$XDG_PICTURES_DIR"/ || true
    rm -rf "$HOME/data/pictures"
fi
if [[ "$XDG_PICTURES_DIR" == /mnt/shared/Pictures ]]; then
    mkdir -p "$HOME/data"
    ln -sfT /mnt/shared/Pictures "$HOME/data/pictures"
fi

mkdir -p "$XDG_PUBLICSHARE_DIR"
if [[ -d "$HOME/Public" ]] &&
    [[ "$XDG_PUBLICSHARE_DIR" != "$HOME/Public" ]]; then
    cp -an "$HOME/Public"/* "$XDG_PUBLICSHARE_DIR"/ || true
    rm -rf "$HOME/Public"
fi

mkdir -p "$XDG_TEMPLATES_DIR"
if [[ -d "$HOME/Templates" ]] &&
    [[ "$XDG_TEMPLATES_DIR" != "$HOME/Templates" ]]; then
    cp -an "$HOME/Templates"/* "$XDG_TEMPLATES_DIR"/ || true
    rm -rf "$HOME/Templates"
fi

mkdir -p "$XDG_VIDEOS_DIR"
if [[ -d "$HOME/Videos" ]] &&
    [[ "$XDG_VIDEOS_DIR" != "$HOME/Videos" ]]; then
    cp -an "$HOME/Videos"/* "$XDG_VIDEOS_DIR"/ || true
    rm -rf "$HOME/Videos"
fi
if [[ -d "$HOME/data/videos" ]] &&
    [[ "$XDG_VIDEOS_DIR" != "$HOME/data/videos" ]]; then
    cp -an "$HOME/data/videos"/* "$XDG_VIDEOS_DIR"/ || true
    rm -rf "$HOME/data/videos"
fi
if [[ "$XDG_VIDEOS_DIR" == /mnt/shared/Movies ]]; then
    mkdir -p "$HOME/data"
    ln -sfT /mnt/shared/Movies "$HOME/data/videos"
fi

# Calibre pre-setup
#
if [[ "$OS" == "Darwin" ]]; then
    mkdir -p "$HOME/Library/Preferences/calibre"
    mkdir -p "$HOME/data/calibre"
fi

# Fix permissions; probably not necessary anymore
#
chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -type d -exec chmod 700 "{}" \;
find "$HOME/.ssh" -type f -exec chmod 600 "{}" \;

chmod 700 "$HOME/.gnupg"
find "$HOME/.gnupg" -type d -exec chmod 700 "{}" \;
find "$HOME/.gnupg" -type f -exec chmod 600 "{}" \;

# Make sure that the GPG environment is set up
#
GPG_TTY=$(tty)
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY SSH_AUTH_SOCK

gpgconf --kill gpg-agent
gpg-connect-agent updatestartuptty /bye

# Set up GPG and SSH, if applicable
#
if [[ $(find "$HOME/.ssh" -type f -iname "id_*" 2>/dev/null | wc -l) -eq 0 ]] &&
    [[ $(gpg --list-secret-keys --with-colons |
        grep -cE '^sec:(f|u):') -eq 0 ]]; then
    # Create a new GPG/SSH keys
    #
    gpg --batch --expert --full-generate-key <<-EOF
	Key-Type: EDDSA
	    Key-Curve: ed25519
	    Key-Usage: sign auth
	Subkey-Type: ECDH
	    Subkey-Curve: cv25519
	    Subkey-Usage: encrypt
	Expire-Date: 0
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
        gpg --list-secret-keys --with-colons "$NEW_SECRET_KEY_ID" |
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
    echo "$NEW_SECRET_KEY_GRIP" >>"$HOME/.gnupg/sshcontrol"

    # Update git signing key
    #
    mkdir -p "$XDG_CONFIG_HOME/git"
    echo "[user]" >"$XDG_CONFIG_HOME/git/gpg.ini"
    echo "    signingkey = $NEW_SECRET_KEY_ID" >>"$XDG_CONFIG_HOME/git/gpg.ini"

    # Print public GPG and SSH keys for new secret key
    #
    echo ""
    echo "-----------------------------------------"
    echo "New secret key 0x$NEW_SECRET_KEY_ID created"
    echo "-----------------------------------------"
    echo ""
    gpg --list-keys --with-keygrip --keyid-format=long "$NEW_SECRET_KEY_ID"
    echo "GPG public key block:"
    echo ""
    gpg --armor --export "$NEW_SECRET_KEY_ID"
    echo ""
    echo "SSH public key:"
    echo ""
    gpg --export-ssh-key "$NEW_SECRET_KEY_ID"
    echo ""
    echo "You must add the public GPG and SSH key displayed above to GitHub before"
    echo "continuing."
    echo ""
    read -rs -n 1 -p "Press any key to continue once this step is complete."
    echo ""
fi

# Install Helix grammars
#
# NOTE: This must be done *after* git is fully setup!
#
hx -g fetch
hx -g build

# Check out a few useful code repositories
#
mkdir -p "$HOME"/src
(
    cd "$HOME"/src || exit 1

    if [[ ! -d hackenv ]]; then
        git clone --recurse-submodules \
            git@github.com:cardboard-iguana/hackenv.git
    fi
    if [[ ! -d smart-contracts-hacking ]]; then
        git clone --recurse-submodules \
            git@github.com:cardboard-iguana/smart-contracts-hacking.git
    fi
    if [[ ! -d resume ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/resume.git
    fi
    if [[ ! -d website-theme ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/website-theme.git
    fi

    if [[ ! -d backups ]]; then
        git clone --recurse-submodules \
            git@github.com:The-Yak-Collective/backups.git
    fi
    if [[ ! -d GPTDiscord ]]; then
        git clone --recurse-submodules \
            git@github.com:The-Yak-Collective/GPTDiscord.git
    fi
    if [[ ! -d yakcollective ]]; then
        git clone --recurse-submodules \
            git@github.com:The-Yak-Collective/yakcollective.git
    fi

    if [[ ! -d cardboard-iguana.com ]]; then
        git clone --recurse-submodules \
            git@github.com:cardboard-iguana/cardboard-iguana.com.git
    fi
    if [[ ! -d chateaumaxmin.info ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/chateaumaxmin.info.git
    fi
    if [[ ! -d delphi-strategy.com ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/delphi-strategy.com.git
    fi
    if [[ ! -d digital-orrery.com ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/digital-orrery.com.git
    fi
    if [[ ! -d necopinus.xyz ]]; then
        git clone --recurse-submodules \
            git@github.com:necopinus/necopinus.xyz.git
    fi

    if [[ ! -d labwc-adwaita ]]; then
        git clone --recurse-submodules \
            https://github.com/davidphilipbarr/labwc-adwaita.git
    fi
    if [[ ! -d KvLibadwaita ]]; then
        git clone --recurse-submodules \
            https://github.com/GabePoel/KvLibadwaita.git
    fi
    if [[ ! -d twitter-archive-parser ]]; then
        git clone --recurse-submodules \
            https://github.com/timhutton/twitter-archive-parser.git
    fi
)

# A reboot is STRONGLY recommended
#
echo ""
echo "Configuration complete!"
echo ""
if [[ "$OS" == "Darwin" ]]; then
    echo "To finish setup you MUST reboot your system NOW."
else
    echo "To finish setup you MUST log out of all sessions NOW."
fi
