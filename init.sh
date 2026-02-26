#!/usr/bin/env bash

set -e

# Set OS type
#
OS="$(uname -s)"

# Sanity check
#
if [[ ! -f "$HOME/.config/nix/flake.nix" ]]; then
    echo "This configuration must be cloned into $HOME/.config/nix!"
    exit
fi

# Work around flakey DNS in the Android VM
#
if [[ "$OS" == "Linux" ]]; then
    if [[ $(grep -c "^nameserver 1.1.1.1" /etc/resolv.conf) -eq 0 ]]; then
        echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
    fi
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
        cd "$HOME/.config/nix"
        sudo -H nix run nix-darwin -- switch --flake .#macos
    )
else
    (
        cd "$HOME/.config/nix"
        dbus-run-session nix run home-manager/master -- switch --flake .#debian
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
        seatd

    # Comment out global SSH option that Nix's ssh binary doesn't like
    #
    sudo sed -i 's/^    GSSAPIAuthentication yes/#   GSSAPIAuthentication yes/' /etc/ssh/ssh_config

    # I mostly exist in US Mountain Time
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
# shellcheck disable=SC1091
source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# Run GPU setup for nixpkgs/home-manager
#
if [[ "$OS" == "Linux" ]]; then
    sudo "$(which non-nixos-gpu-setup)"
fi

# Set up XDG user directories
#
if [[ "$XDG_DOCUMENTS_DIR" == /mnt/shared/Documents ]]; then
    ln -sfT /mnt/shared/Documents "$HOME/Document"
else
    mkdir -p "$XDG_DOCUMENTS_DIR"
fi
mkdir -p "$XDG_DESKTOP_DIR"
if [[ "$XDG_DOWNLOAD_DIR" == /mnt/shared/Download ]]; then
    ln -sfT /mnt/shared/Download "$HOME/Downloads"
else
    mkdir -p "$XDG_DOWNLOAD_DIR"
fi
if [[ "$XDG_MUSIC_DIR" == /mnt/shared/Music ]]; then
    ln -sfT /mnt/shared/Music "$HOME/Music"
else
    mkdir -p "$XDG_MUSIC_DIR"
fi
if [[ "$XDG_PICTURES_DIR" == /mnt/shared/Pictures ]]; then
    ln -sfT /mnt/shared/Pictures "$HOME/Pictures"
else
    mkdir -p "$XDG_PICTURES_DIR"
fi
mkdir -p "$XDG_PUBLICSHARE_DIR"
mkdir -p "$XDG_TEMPLATES_DIR"
if [[ "$XDG_VIDEOS_DIR" == /mnt/shared/Movies ]]; then
    ln -sfT /mnt/shared/Movies "$HOME/Videos"
else
    mkdir -p "$XDG_VIDEOS_DIR"
fi

# Calibre pre-setup
#
if [[ "$OS" == "Darwin" ]]; then
    mkdir -p "$HOME/Library/Preferences/calibre"
    mkdir -p "$HOME/Documents/Calibre"
fi

# Make sure that SSH is set up
#
chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -type d -exec chmod 700 "{}" \;
find "$HOME/.ssh" -type f -exec chmod 600 "{}" \;

if [[ $(find "$HOME/.ssh" -mindepth 1 -maxdepth 1 -type f -iname "id_ed25519" 2>/dev/null | wc -l) -eq 0 ]]; then
    ssh-keygen -C "Nathan Acks <nathan.acks@cardboard-iguana.com> ($(date)) [$USER@$(hostname)]" -f "$HOME"/.ssh/id_ed25519 -t ed25519
    echo ""
    echo "-------------------"
    echo "New SSH key created"
    echo "-------------------"
    echo ""
    cat "$HOME"/.ssh/id_ed25519.pub
    echo ""
    echo "You must add the public SSH key displayed above to GitHub (as BOTH an"
    echo "authentication AND signing key) before continuing."
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
mkdir -p "$HOME"/Projects
(
    cd "$HOME"/Projects || exit 1

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
