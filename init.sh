#!/usr/bin/env bash

set -e

# Sanity check
#
if [[ ! -f "$HOME/.config/nix/flake.nix" ]]; then
    echo "This configuration must be cloned into $HOME/.config/nix!"
    exit
fi

# Set OS type
#
OS="$(uname -s)"

# Make sure our user has unrestricted sudo access on Linux
# 
if [[ "$OS" == "Linux" ]]; then
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER"
fi

# Work around flakey DNS in the Android VM
#
if [[ "$USER" == "droid" ]]; then
    sudo tee /etc/resolv.conf <<-EOF
	nameserver 1.1.1.1
	nameserver 8.8.8.8
	nameserver 8.8.4.4
	EOF
fi

# Install (or set up) Homebrew on macOS
#
if [[ "$OS" == "Darwin" ]]; then
    if [[ ! -x /opt/homebrew/bin/brew ]] && [[ ! -x /usr/local/bin/brew ]]; then
        xcode-select --install || true
        until xcode-select -p &>/dev/null; do
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

# Make sure that required packages are installed on Linux
#
if [[ "$OS" == "Linux" ]]; then
    # Keep installation slim on Linux
    #
    sudo mkdir -p /etc/apt/apt.conf.d
    sudo tee /etc/apt/apt.conf.d/99local <<-EOF
	APT::Install-Recommends "0";
	APT::Install-Suggests "0";
	EOF

    # Make all repositories available, we're not picky
    # 
    if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
        sudo sed -i 's#^Components: .*$#Components: main contrib non-free non-free-firmware#' /etc/apt/sources.list.d/debian.sources
    elif [[ -f /etc/apt/sources.list.d/ubuntu.sources ]]; then
        sudo sed -i 's#^Components: .*$#Components: main universe multiverse restricted#' /etc/apt/sources.list.d/ubuntu.sources
    else
        sudo sed -i 's# main$# main contrib non-free non-free-firmware#' /etc/apt/sources.list
    fi

    # Update, install, claen
    # 
    sudo apt update -y
    sudo apt full-upgrade -y

    sudo apt install -y \
        bubblewrap \
        build-essential \
        curl \
        dialog \
        libseccomp-dev \
        man-db \
        procps \
        uuid-runtime

    sudo apt autoremove -y --purge --autoremove
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

# Linux configuration tweaks
#
if [[ "$OS" == "Linux" ]]; then
    # Comment out global SSH option that Nix's ssh binary doesn't like
    #
    sudo sed -i 's/^    GSSAPIAuthentication yes/#   GSSAPIAuthentication yes/' /etc/ssh/ssh_config

    # Make sure that our custom GIT_SIGNING_KEY environment variable can be passed over SSH
    #
    if [[ $(grep -c "GIT_SIGNING_KEY" /etc/ssh/ssh_config) -eq 0 ]]; then
        sudo sed -i 's/^#   SendEnv /    SendEnv /' /etc/ssh/ssh_config
        sudo sed -i 's/^    SendEnv /    SendEnv GIT_SIGNING_KEY /' /etc/ssh/ssh_config
    fi
    if [[ $(grep -c "GIT_SIGNING_KEY" /etc/ssh/sshd_config) -eq 0 ]]; then
        sudo sed -i 's/^#AcceptEnv /AcceptEnv /' /etc/ssh/sshd_config
        sudo sed -i 's/^AcceptEnv /AcceptEnv GIT_SIGNING_KEY /' /etc/ssh/sshd_config
    fi
    if [[ -f /exe.dev/etc/ssh/sshd_config ]] && [[ $(grep -c "GIT_SIGNING_KEY" /etc/ssh/sshd_config) -eq 0 ]]; then
        sudo sed -i 's/^#AcceptEnv /AcceptEnv /' /exe.dev/etc/ssh/sshd_config
        sudo sed -i 's/^AcceptEnv /AcceptEnv GIT_SIGNING_KEY /' /exe.dev/etc/ssh/sshd_config
    fi

    # I mostly exist in US Mountain Time
    #
    sudo ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime

    # Tweak Android terminal theme
    #
    if [[ -f /etc/systemd/system/ttyd.service ]] && [[ $(grep -c theme /etc/systemd/system/ttyd.service) -eq 0 ]]; then
      # Gruvbox Dark
      # 
      #sudo sed -i "s/-t disableLeaveAlert=true/-t disableLeaveAlert=true -t fontFamily=monospace -t fontSize=14 -t 'theme={\"foreground\":\"#ebdbb2\",\"background\":\"#282828\",\"cursor\":\"#928374\",\"cursorAccent\":\"#fbf1c7\",\"selectionBackground\":\"#504945\",\"selectionForeground\":\"#fbf1c7\",\"black\":\"#282828\",\"red\":\"#cc241d\",\"green\":\"#98971a\",\"yellow\":\"#d79921\",\"blue\":\"#458588\",\"magenta\":\"#b16286\",\"cyan\":\"#689d6a\",\"white\":\"#a89984\",\"brightBlack\":\"#928374\",\"brightRed\":\"#fb4934\",\"brightGreen\":\"#b8bb26\",\"brightYellow\":\"#fabd2f\",\"brightBlue\":\"#83a598\",\"brightMagenta\":\"#d3869b\",\"brightCyan\":\"#8ec07c\",\"brightWhite\":\"#ebdbb2\"}'/" /etc/systemd/system/ttyd.service

      # Gruvbox Light
      # 
      sudo sed -i "s/-t disableLeaveAlert=true/-t disableLeaveAlert=true -t fontFamily=monospace -t fontSize=14 -t 'theme={\"foreground\":\"#3c3836\",\"background\":\"#fbf1c7\",\"cursor\":\"#928374\",\"cursorAccent\":\"#282828\",\"selectionBackground\":\"#d5c4a1\",\"selectionForeground\":\"#282828\",\"black\":\"#fbf1c7\",\"red\":\"#cc241d\",\"green\":\"#98971a\",\"yellow\":\"#d79921\",\"blue\":\"#458588\",\"magenta\":\"#b16286\",\"cyan\":\"#689d6a\",\"white\":\"#7c6f64\",\"brightBlack\":\"#928374\",\"brightRed\":\"#9d0006\",\"brightGreen\":\"#79740e\",\"brightYellow\":\"#b57614\",\"brightBlue\":\"#076678\",\"brightMagenta\":\"#8f3f71\",\"brightCyan\":\"#427b58\",\"brightWhite\":\"#3c3836\"}'/" /etc/systemd/system/ttyd.service
    fi
fi

# Clear out macOS settings that need to be set (or not set) explicitly
#
if [[ "$OS" == "Darwin" ]]; then
    defaults delete kCFPreferencesAnyApplication AppleAccentColor 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleHighlightColor 2>/dev/null || true
    defaults delete kCFPreferencesAnyApplication AppleIconAppearanceTintColor 2>/dev/null || true
fi

# Move files that we might overwrite out of the way
#
if [[ "$OS" == "Darwin" ]]; then
    if [[ -e /etc/bashrc ]]; then
        sudo mv /etc/bashrc "/etc/bashrc.$(date "+%Y%m%d%H%M%S")"
    fi
    if [[ -e /etc/pam.d/sudo_local ]]; then
        sudo mv /etc/pam.d/sudo_local "/etc/pam.d/sudo_local.$(date "+%Y%m%d%H%M%S")"
    fi
    if [[ -e /etc/zprofile ]]; then
        sudo mv /etc/zprofile "/etc/zprofile.$(date "+%Y%m%d%H%M%S")"
    fi
    if [[ -e /etc/zshenv ]]; then
        sudo mv /etc/zshenv "/etc/zshenv.$(date "+%Y%m%d%H%M%S")"
    fi
    if [[ -e /etc/zshrc ]]; then
        sudo mv /etc/zshrc "/etc/zshrc.$(date "+%Y%m%d%H%M%S")"
    fi
fi
if [[ -e "$HOME"/.bashrc ]]; then
    mv "$HOME"/.bashrc "$HOME/.bashrc.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.claude/CLAUDE.md ]]; then
    mv "$HOME"/.claude/CLAUDE.md "$HOME/.claude/CLAUDE.md.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.claude/settings.json ]]; then
    mv "$HOME"/.claude/settings.json "$HOME/.claude/settings.json.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.codex/AGENTS.md ]]; then
    mv "$HOME"/.codex/AGENTS.md "$HOME/.codex/AGENTS.md.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.codex/config.toml ]]; then
    mv "$HOME"/.codex/config.toml "$HOME/.codex/config.toml.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.config/claude/CLAUDE.md ]]; then
    mv "$HOME"/.config/claude/CLAUDE.md "$HOME/.config/claude/CLAUDE.md.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.config/claude/settings.json ]]; then
    mv "$HOME"/.config/claude/settings.json "$HOME/.config/claude/settings.json.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.config/codex/AGENTS.md ]]; then
    mv "$HOME"/.config/codex/AGENTS.md "$HOME/.config/codex/AGENTS.md.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.config/codex/config.toml ]]; then
    mv "$HOME"/.config/codex/config.toml "$HOME/.config/codex/config.toml.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.gemini/GEMINI.md ]]; then
    mv "$HOME"/.gemini/GEMINI.md "$HOME/.gemini/GEMINI.md.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.gemini/antigravity-cli/settings.json ]]; then
    mv "$HOME"/.gemini/antigravity-cli/settings.json "$HOME/.gemini/antigravity-cli/settings.json.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.profile ]]; then
    mv "$HOME"/.profile "$HOME/.profile.$(date "+%Y%m%d%H%M%S")"
fi

# Build configuration
#
(
    cd "$HOME/.config/nix" || exit 1

    if [[ "$OS" == "Darwin" ]]; then
        sudo -H nix run nix-darwin -- switch --flake .#macos
    elif [[ "$USER" == "droid" ]]; then
        nix run home-manager/master -- switch --flake .#android
    elif [[ "$USER" == "exedev" ]]; then
        nix run home-manager/master -- switch --flake .#exedev
    else
        nix run home-manager/master -- switch --flake .#linux
    fi
)

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

# Garbage collection
#
nix-collect-garbage --delete-older-than 14d
sudo find /nix/var/nix/gcroots -xtype l -exec rm -v "{}" \;
nix store gc -v
nix store optimise -v
echo ""

# Make sure that SSH is set up on macOS and Android (agent forwarding is
# used for Linux VMs and exe.dev)
#
if [[ "$OS" == "Darwin" ]] || [[ "$USER" == "droid" ]]; then
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
fi

# Check out a few useful code repositories
#
if [[ "$OS" == "Darwin" ]] || [[ "$USER" == "droid" ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        mkdir -p "$HOME"/Projects
    else
        mkdir -p "$HOME"/src
    fi

    (
        if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$HOME/Projects" ]]; then
            cd "$HOME/Projects" || exit 1
        elif [[ "$(uname -s)" == "Linux" ]] && [[ -d "$HOME/src" ]]; then
            cd "$HOME/src" || exit 1
        else
            exit 1
        fi

        REPOS="$( (
            curl -sL -X GET \
                 -H "Accept: application/vnd.github+json" \
                 -H "X-GitHub-Api-Version: 2026-03-10" \
                    https://api.github.com/users/necopinus/repos && \
            curl -sL -X GET \
                 -H "Accept: application/vnd.github+json" \
                 -H "X-GitHub-Api-Version: 2026-03-10" \
                    https://api.github.com/orgs/cardboard-iguana/repos && \
            curl -sL -X GET \
                 -H "Accept: application/vnd.github+json" \
                 -H "X-GitHub-Api-Version: 2026-03-10" \
                    https://api.github.com/orgs/The-Yak-Collective/repos ) | \
            jq -r '.[] | select(.archived==false) | .full_name' | xargs
        )"

        for REPO in $REPOS; do
            if [[ ! -d "$(basename "$REPO")" ]]; then
                git clone --recurse-submodules \
                    "git@github.com:${REPO}.git"
            fi
        done

        if [[ ! -d hacker-hotel ]]; then
            git clone --recurse-submodules \
                git@github.com:cardboard-iguana/hacker-hotel.git
        fi
        if [[ ! -d smart-contracts-hacking ]]; then
            git clone --recurse-submodules \
                git@github.com:cardboard-iguana/smart-contracts-hacking.git
        fi

        if [[ ! -d quartz ]]; then
            git clone --recurse-submodules \
                https://github.com/jackyzha0/quartz.git
        fi
        if [[ ! -d twitter-archive-parser ]]; then
            git clone --recurse-submodules \
                https://github.com/timhutton/twitter-archive-parser.git
        fi
    )
fi

# A reboot is STRONGLY recommended
#
echo ""
echo "Configuration complete!"
echo ""
echo "You MUST restart the system NOW."
