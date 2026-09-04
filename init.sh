#!/usr/bin/env bash

set -e

# Sanity check
#
if [[ ! -f "$HOME/.config/nix/flake.nix" ]]; then
  echo "This configuration must be cloned into $HOME/.config/nix!"
  exit
fi

# Set OS type and HOST_NAME
#
OS="$(uname -s)"
HOST_NAME="$(hostname)"

# Make sure our user has unrestricted sudo access on Linux
#
if [[ "$OS" == "Linux" ]]; then
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER"
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

  # Ensure that expected system packages are installed
  #
  sudo apt install -y \
    adb \
    bind9-dnsutils \
    build-essential \
    ca-certificates \
    coreutils \
    cron \
    curl \
    dialog \
    diffutils \
    dos2unix \
    espeak-ng \
    eza \
    fastboot \
    ffmpeg \
    findutils \
    flac \
    fonts-freefont-ttf \
    fonts-ipafont-gothic \
    fonts-liberation \
    fonts-linuxlibertine \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-noto-extra \
    fonts-tlwg-loma-otf \
    fonts-unifont \
    fonts-wqy-zenhei \
    gawk \
    git \
    gnu-which \
    grep \
    imagemagick \
    jq \
    kid3-cli \
    libasound2t64 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libatspi2.0-0t64 \
    libcairo2 \
    libcups2t64 \
    libdbus-1-3 \
    libdrm2 \
    libffi-dev \
    libfontconfig1 \
    libfreetype6 \
    libgbm1 \
    libglib2.0-0t64 \
    libjpeg-turbo-progs \
    libnspr4 \
    libnss3 \
    libopus0 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    man-db \
    openssh-client \
    optipng \
    pdftk-java \
    poppler-utils \
    procps \
    python3-dev \
    qalc \
    ripgrep \
    rsgain \
    rsync \
    sed \
    tar \
    texlive \
    texlive-xetex \
    tmux \
    unzip \
    uuid-runtime \
    xfonts-cyrillic \
    xfonts-scalable \
    xvfb \
    xz-utils \
    yubikey-manager \
    zip

  sudo apt autoremove -y --purge --autoremove
fi

# Install Nix
#
if [[ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
fi
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091  # path is only valid after Nix is installed
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [[ ! -f /etc/nix/nix.custom.conf ]] || [[ $(grep -c "^trusted-users = " /etc/nix/nix.custom.conf) -eq 0 ]]; then
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
  # I mostly exist in US Mountain Time
  #
  sudo ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime

  # Tweak Android terminal theme
  #
  if [[ "$USER" == "droid" ]] && [[ -f /etc/systemd/system/ttyd_uds.service ]] && [[ $(grep -c theme /etc/systemd/system/ttyd_uds.service) -eq 0 ]]; then
    # Gruvbox Dark
    #
    #sudo sed -i "s/-t disableLeaveAlert=true/-t disableLeaveAlert=true -t fontFamily=monospace -t fontSize=14 -t 'theme={\"foreground\":\"#ebdbb2\",\"background\":\"#282828\",\"cursor\":\"#928374\",\"cursorAccent\":\"#fbf1c7\",\"selectionBackground\":\"#504945\",\"selectionForeground\":\"#fbf1c7\",\"black\":\"#282828\",\"red\":\"#cc241d\",\"green\":\"#98971a\",\"yellow\":\"#d79921\",\"blue\":\"#458588\",\"magenta\":\"#b16286\",\"cyan\":\"#689d6a\",\"white\":\"#a89984\",\"brightBlack\":\"#928374\",\"brightRed\":\"#fb4934\",\"brightGreen\":\"#b8bb26\",\"brightYellow\":\"#fabd2f\",\"brightBlue\":\"#83a598\",\"brightMagenta\":\"#d3869b\",\"brightCyan\":\"#8ec07c\",\"brightWhite\":\"#ebdbb2\"}'/" /etc/systemd/system/ttyd_uds.service

    # Gruvbox Light
    #
    sudo sed -i "s/-t disableLeaveAlert=true/-t disableLeaveAlert=true -t fontFamily=monospace -t fontSize=14 -t 'theme={\"foreground\":\"#3c3836\",\"background\":\"#fbf1c7\",\"cursor\":\"#928374\",\"cursorAccent\":\"#282828\",\"selectionBackground\":\"#d5c4a1\",\"selectionForeground\":\"#282828\",\"black\":\"#fbf1c7\",\"red\":\"#cc241d\",\"green\":\"#98971a\",\"yellow\":\"#d79921\",\"blue\":\"#458588\",\"magenta\":\"#b16286\",\"cyan\":\"#689d6a\",\"white\":\"#7c6f64\",\"brightBlack\":\"#928374\",\"brightRed\":\"#9d0006\",\"brightGreen\":\"#79740e\",\"brightYellow\":\"#b57614\",\"brightBlue\":\"#076678\",\"brightMagenta\":\"#8f3f71\",\"brightCyan\":\"#427b58\",\"brightWhite\":\"#3c3836\"}'/" /etc/systemd/system/ttyd_uds.service
  fi

  if [[ "$HOST_NAME" == "kitsune" ]]; then
    # Disable user namespace AppArmor enforcement if we're (1) on
    # Ubuntu and (2) installing Hermes, as it prevents SUID binaries
    # (i.e., the Chromium sandbox) from running in the Nix store
    # (and thus breaks Hermes' browser automation)
    #
    #   https://github.com/NixOS/nixpkgs/issues/121694
    #
    if [[ $(grep -c "ID=ubuntu" /etc/os-release) -ne 0 ]]; then
      echo "kernel.apparmor_restrict_unprivileged_userns=0" | sudo tee /etc/sysctl.d/60-apparmor-disable-userns-restrictions.conf
    fi

    # Install Hermes
    #
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

    # Install Mnemosyne
    #
    if [[ -d "$HOME/.hermes/mnemosyne-venv" ]]; then
      rm -rf "$HOME/.hermes/mnemosyne-venv"
    fi
    uv venv "$HOME/.hermes/mnemosyne-venv"
    (
      cd "$HOME/.hermes/mnemosyne-venv"
      uv pip install "fastembed" "mnemosyne-memory[embeddings]" "mnemosyne-hermes"
      uv run mnemosyne-hermes --hermes-home "$HOME/.hermes" install --force --mode wrapper --python "$HOME/.hermes/mnemosyne-venv/bin/python"
    )

    # Install Hermes WebUI
    #
    if [[ -d "$HOME/.hermes/hermes-webui" ]]; then
      rm -rf "$HOME/.hermes/hermes-webui"
    fi
    git clone https://github.com/nesquena/hermes-webui.git "$HOME/.hermes/hermes-webui"

    # Install `xurl` searxh tool
    #
    curl -fsSL https://raw.githubusercontent.com/xdevplatform/xurl/main/install.sh | bash

    # Create systemd service files
    #
    sudo tee /etc/systemd/system/hermes-dashboard.service <<-EOF
			[Unit]
			Description=Hermes Agent Dashboard - Online Portal
			After=network-online.target
			Wants=network-online.target
			StartLimitIntervalSec=0

			[Service]
			Type=simple
			User=$USER
			Group=$USER
			ExecStart=$HOME/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main dashboard --host 0.0.0.0 --no-open
			WorkingDirectory=$HOME/.hermes
			Environment="HOME=$HOME"
			Environment="USER=$USER"
			Environment="LOGNAME=$USER"
			Environment="PATH=$HOME/.hermes/hermes-agent/venv/bin:$HOME/.hermes/hermes-agent/node_modules/.bin:$HOME/.hermes/node/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/bin:/usr/bin:/sbin:/usr/sbin:/exe.dev/bin:/usr/local/bin"
			Environment="VIRTUAL_ENV=$HOME/.hermes/hermes-agent/venv"
			Environment="HERMES_HOME=$HOME/.hermes"
			Restart=always
			RestartSec=5
			RestartForceExitStatus=75
			RestartPreventExitStatus=78
			KillMode=mixed
			KillSignal=SIGTERM
			ExecReload=/bin/kill -USR1 \$MAINPID
			TimeoutStopSec=60
			StandardOutput=journal
			StandardError=journal

			[Install]
			WantedBy=multi-user.target
		EOF
    sudo ln -s /etc/systemd/system/hermes-dashboard.service /etc/systemd/system/multi-user.target.wants/hermes-dashboard.service

    sudo tee /etc/systemd/system/hermes-gateway.service <<-EOF
			[Unit]
			Description=Hermes Agent Gateway - Messaging Platform Integration
			After=network-online.target
			Wants=network-online.target
			StartLimitIntervalSec=0

			[Service]
			Type=simple
			User=$USER
			Group=$USER
			ExecStart=$HOME/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main gateway run
			WorkingDirectory=$HOME/.hermes
			Environment="HOME=$HOME"
			Environment="USER=$USER"
			Environment="LOGNAME=$USER"
			Environment="PATH=$HOME/.hermes/hermes-agent/venv/bin:$HOME/.hermes/hermes-agent/node_modules/.bin:$HOME/.heres/node/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/bin:/usr/bin:/sbin:/usr/sbin:/exe.dev/bin:/usr/local/bin"
			Environment="VIRTUAL_ENV=$HOME/.hermes/hermes-agent/venv"
			Environment="HERMES_HOME=$HOME/.hermes"
			Restart=always
			RestartSec=5
			RestartForceExitStatus=75
			RestartPreventExitStatus=78
			KillMode=mixed
			KillSignal=SIGTERM
			ExecReload=/bin/kill -USR1 \$MAINPID
			ExecStopPost=-$HOME/.hermes/hermes-agent/venv/bin/python -m gateway.cgroup_cleanup
			TimeoutStopSec=60
			StandardOutput=journal
			StandardError=journal

			[Install]
			WantedBy=multi-user.target
		EOF
    sudo ln -s /etc/systemd/system/hermes-gateway.service /etc/systemd/system/multi-user.target.wants/hermes-gateway.service

    sudo tee /etc/systemd/system/hermes-webui.service <<-EOF
			[Unit]
			Description=Hermes WebUI
			After=network-online.target
			Wants=network-online.target
			StartLimitIntervalSec=0

			[Service]
			Type=simple
			User=$USER
			Group=$USER
			ExecStart=$HOME/.hermes/hermes-agent/venv/bin/python $HOME/.hermes/hermes-webui/bootstrap.py --no-browser --skip-agent-install --foreground
			WorkingDirectory=$HOME/.hermes/hermes-agent
			Environment="HOME=$HOME"
			Environment="USER=$USER"
			Environment="LOGNAME=$USER"
			Environment="PATH=$HOME/.hermes/hermes-agent/venv/bin:$HOME/.hermes/hermes-agent/node_modules/.bin:$HOME/.hermes/node/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/bin:/usr/bin:/sbin:/usr/sbin:/exe.dev/bin:/usr/local/bin"
			Environment="VIRTUAL_ENV=$HOME/.hermes/hermes-agent/venv"
			Environment="HERMES_HOME=$HOME/.hermes"
			Environment="REPO_ROOT=$HOME/.hermes/hermes-webui"
			Restart=always
			RestartSec=5
			RestartForceExitStatus=75
			RestartPreventExitStatus=78
			KillMode=mixed
			KillSignal=SIGTERM
			ExecReload=/bin/kill -USR1 \$MAINPID
			TimeoutStopSec=60
			StandardOutput=journal
			StandardError=journal

			[Install]
			WantedBy=multi-user.target
		EOF
    sudo ln -s /etc/systemd/system/hermes-webui.service /etc/systemd/system/multi-user.target.wants/hermes-webui.service

    sudo systemctl daemon-reload
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
# Each moved file is parked under ~/.moved-paths/<timestamp>/<original
# path>/<original name>, preserving the original location in the path
# structure so it's easy to identify what was moved and from where.
#
if [[ "$OS" == "Darwin" ]]; then
  MOVED_BASE="$HOME/.moved-paths/$(date '+%Y%m%d%H%M%S')"
  for FILE in /etc/bashrc /etc/pam.d/sudo_local /etc/zprofile /etc/zshenv /etc/zshrc; do
    if [[ -e "$FILE" ]]; then
      DEST_DIR="$MOVED_BASE$FILE"
      sudo mkdir -p "$DEST_DIR"
      sudo mv "$FILE" "$DEST_DIR/$(basename "$FILE")"
    fi
  done
fi
if [[ -e "$HOME"/.bashrc ]]; then
  mv "$HOME"/.bashrc "$HOME/.bashrc.$(date "+%Y%m%d%H%M%S")"
fi
if [[ -e "$HOME"/.profile ]]; then
  mv "$HOME"/.profile "$HOME/.profile.$(date "+%Y%m%d%H%M%S")"
fi

# Build configuration
#
(
  cd "$HOME/.config/nix" || exit 1

  if [[ "$OS" == "Darwin" ]]; then
    sudo -H nix run nix-darwin -- switch --flake .?submodules=1#macos
  elif [[ "$HOST_NAME" == "kitsune" ]]; then
    nix run home-manager/master -- switch --flake .?submodules=1#hermes
  elif [[ "$USER" == "droid" ]]; then
    nix run home-manager/master -- switch --flake .?submodules=1#android
  elif [[ "$USER" == "exedev" ]]; then
    nix run home-manager/master -- switch --flake .?submodules=1#exedev
  else
    nix run home-manager/master -- switch --flake .?submodules=1#linux
  fi
)

# Update runtime environment
#
unset __ETC_PROFILE_NIX_SOURCED
# shellcheck disable=SC1091  # path is only valid after Nix is installed
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
nix-collect-garbage -d
sudo find /nix/var/nix/gcroots -xtype l -exec rm -v {} +
nix store gc -v
nix store optimise -v

# Install Hermes completions, if applicable
#
if [[ -n "$(which hermes 2>/dev/null)" ]]; then
  if [[ -d "$HOME"/.hermes/skills/officecli ]]; then
    rm -rf "$HOME"/.hermes/skills/officecli
  fi
  officecli skill install
  if [[ -d "$HOME"/.claude/skills/officecli ]]; then
    rm -rf "$HOME"/.claude/skills/officecli
  fi
  if [[ -d "$XDG_CONFIG_HOME"/bash ]]; then
    if [[ ! -d "$XDG_CONFIG_HOME"/bash/rc.d ]]; then
      mkdir -p "$XDG_CONFIG_HOME"/bash/rc.d
    fi
    hermes completion bash >"$XDG_CONFIG_HOME"/bash/rc.d/hermes-completion.sh
  fi
  if [[ -d "$XDG_CONFIG_HOME"/zsh ]]; then
    if [[ ! -d "$XDG_CONFIG_HOME"/zsh/rc.d ]]; then
      mkdir -p "$XDG_CONFIG_HOME"/zsh/rc.d
    fi
    hermes completion zsh >"$XDG_CONFIG_HOME"/zsh/rc.d/hermes-completion.zsh
  fi
  if [[ -d "$XDG_CONFIG_HOME"/fish ]]; then
    if [[ ! -d "$XDG_CONFIG_HOME"/fish/completions ]]; then
      mkdir -p "$XDG_CONFIG_HOME"/fish/completions
    fi
    hermes completion fish >"$XDG_CONFIG_HOME"/fish/completions/hermes.fish
  fi
fi

# Make sure that SSH is set up on macOS and Android (agent forwarding is
# used for Linux VMs and exe.dev)
#
if [[ "$OS" == "Darwin" ]] || [[ "$USER" == "droid" ]] || [[ "$HOST_NAME" == "kitsune" ]]; then
  chmod 700 "$HOME/.ssh"
  find "$HOME/.ssh" -type d -exec chmod 700 "{}" \;
  find "$HOME/.ssh" -type f -exec chmod 600 "{}" \;

  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    if [[ "$HOST_NAME" == "kitsune" ]]; then
      ssh-keygen -C "Inaba <inaba@cardboard-iguana.com> ($(date)) [$USER@$HOST_NAME]" -f "$HOME"/.ssh/id_ed25519 -t ed25519
    else
      ssh-keygen -C "Nathan Acks <nathan.acks@cardboard-iguana.com> ($(date)) [$USER@$HOST_NAME]" -f "$HOME"/.ssh/id_ed25519 -t ed25519
    fi
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
    if [[ "$OS" == "Darwin" ]] && [[ -d "$HOME/Projects" ]]; then
      cd "$HOME/Projects" || exit 1
    elif [[ "$USER" == "droid" ]] && [[ -d "$HOME/src" ]]; then
      cd "$HOME/src" || exit 1
    else
      exit 1
    fi

    REPOS="$(
      (
        curl -sL -X GET \
          -H "Accept: application/vnd.github+json" \
          -H "X-GitHub-Api-Version: 2026-03-10" \
          https://api.github.com/users/necopinus/repos &&
          curl -sL -X GET \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2026-03-10" \
            https://api.github.com/orgs/cardboard-iguana/repos &&
          curl -sL -X GET \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2026-03-10" \
            https://api.github.com/orgs/The-Yak-Collective/repos
      ) |
        jq -r '.[] | select(.archived==false) | .full_name' | xargs
    )"

    for REPO in $REPOS; do
      if [[ ! -d "$(basename "$REPO")" ]]; then
        git clone --recurse-submodules \
          "git@github.com:${REPO}.git"
      fi
    done

    if [[ ! -d quartz ]]; then
      git clone --recurse-submodules \
        https://github.com/jackyzha0/quartz.git
    fi
    if [[ ! -d twitter-archive-parser ]]; then
      git clone --recurse-submodules \
        https://github.com/timhutton/twitter-archive-parser.git
    fi

    if [[ "$OS" == "Darwin" ]]; then
      mkdir -p "$HOME/Documents/Obsidian"
      while IFS= read -r -d '' VAULT_REPO; do
        VAULT_NAME="$(basename "$VAULT_REPO" | sed "s/^obsidian-//")"
        mv "$VAULT_REPO" "$HOME/Documents/Obsidian/$VAULT_NAME"
      done < <(find . -mindepth 1 -maxdepth 1 -type d -iname 'obsidian-*' -print0)
    elif [[ "$USER" == "droid" ]]; then
      rm -rf obsidian-* || true
    fi
  )
fi

# A reboot is STRONGLY recommended
#
echo ""
echo "Configuration complete!"
echo ""
echo "You MUST restart the system NOW."
