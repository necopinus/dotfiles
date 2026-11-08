#!/usr/bin/env bash

set -e
set -o pipefail

# Sanity check
#
if [[ ! -f "$HOME/.config/nix/flake.nix" ]]; then
  echo "This configuration must be cloned into $HOME/.config/nix!"
  exit 1
fi

# Set OS type and HOST_NAME
#
OS="$(uname -s)"
HOST_NAME="$(hostname -s)"

# Make sure our user has unrestricted sudo access on Linux. Validate the rule
# before installing it with the ownership and permissions sudo expects.
#
if [[ "$OS" == "Linux" ]]; then
  CURRENT_USER="$(id -un)"
  SUDOERS_TMP="$(mktemp)"
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$CURRENT_USER" >"$SUDOERS_TMP"
  if ! sudo visudo -cf "$SUDOERS_TMP"; then
    rm -f "$SUDOERS_TMP"
    exit 1
  fi
  if ! sudo install -o root -g root -m 0440 "$SUDOERS_TMP" "/etc/sudoers.d/$CURRENT_USER"; then
    rm -f "$SUDOERS_TMP"
    exit 1
  fi
  rm -f "$SUDOERS_TMP"
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
fi

# Clear out macOS settings that need to be set (or not set) explicitly
#
if [[ "$OS" == "Darwin" ]]; then
  defaults delete kCFPreferencesAnyApplication AppleAccentColor 2>/dev/null || true
  defaults delete kCFPreferencesAnyApplication AppleHighlightColor 2>/dev/null || true
  defaults delete kCFPreferencesAnyApplication AppleIconAppearanceTintColor 2>/dev/null || true
fi

# Disable GSSAPIAuthentication, as this breaks Nix's SSH client
#
if [[ -f /etc/ssh/ssh_config ]]; then
  sudo sed -i 's/^    GSSAPIAuthentication yes/#   GSSAPIAuthentication yes/' /etc/ssh/ssh_config
fi

# Move files that we might overwrite out of the way before activation, but
# restore them if activation fails. The backups use unique paths so repeated
# runs cannot overwrite an earlier recovery copy.
#
MOVED_BASE=""
BASHRC_BACKUP="$(mktemp "$HOME/.bashrc.XXXXXX")"
PROFILE_BACKUP="$(mktemp "$HOME/.profile.XXXXXX")"
BASHRC_EXISTED=0
PROFILE_EXISTED=0
RESTORE_NEEDED=1
if [[ -e "$HOME"/.bashrc ]]; then
  BASHRC_EXISTED=1
fi
if [[ -e "$HOME"/.profile ]]; then
  PROFILE_EXISTED=1
fi

if [[ "$OS" == "Darwin" ]]; then
  mkdir -p "$HOME/.moved-paths"
  MOVED_BASE="$(mktemp -d "$HOME/.moved-paths/XXXXXX")"
  for FILE in /etc/bashrc /etc/pam.d/sudo_local /etc/zprofile /etc/zshenv /etc/zshrc; do
    if [[ -e "$FILE" ]]; then
      DEST_DIR="$MOVED_BASE$FILE"
      sudo mkdir -p "$DEST_DIR"
      sudo mv "$FILE" "$DEST_DIR/$(basename "$FILE")"
    fi
  done
fi

trap '
  if [[ "$RESTORE_NEEDED" == 1 ]]; then
    if [[ "$OS" == "Darwin" ]]; then
      for FILE in /etc/bashrc /etc/pam.d/sudo_local /etc/zprofile /etc/zshenv /etc/zshrc; do
        if [[ -e "$MOVED_BASE$FILE/$(basename "$FILE")" ]]; then
          sudo mv "$MOVED_BASE$FILE/$(basename "$FILE")" "$FILE" || true
        fi
      done
    fi
    if [[ "$BASHRC_EXISTED" == 1 ]]; then
      mv "$BASHRC_BACKUP" "$HOME/.bashrc" || true
    else
      rm -f "$BASHRC_BACKUP"
    fi
    if [[ "$PROFILE_EXISTED" == 1 ]]; then
      mv "$PROFILE_BACKUP" "$HOME/.profile" || true
    else
      rm -f "$PROFILE_BACKUP"
    fi
  fi
' EXIT

if [[ "$BASHRC_EXISTED" == 1 ]]; then
  mv "$HOME"/.bashrc "$BASHRC_BACKUP"
fi
if [[ "$PROFILE_EXISTED" == 1 ]]; then
  mv "$HOME"/.profile "$PROFILE_BACKUP"
fi

# Build configuration
#
(
  cd "$HOME/.config/nix" || exit 1

  activateConfiguration() {
    local configuration="$1"
    local activation
    activation="$(nix build "$configuration" --no-link --print-out-paths)"
    if [[ ! -x "$activation/activate" ]]; then
      echo "Activation script not found for $configuration" >&2
      return 1
    fi
    if [[ "$OS" == "Darwin" ]]; then
      sudo -H "$activation/activate"
    else
      "$activation/activate"
    fi
  }

  if [[ "$OS" == "Darwin" ]]; then
    activateConfiguration .#darwinConfigurations.macos.system
  elif [[ "$HOST_NAME" == "kitsune" ]]; then
    activateConfiguration .#homeConfigurations.hermes.activationPackage
  elif [[ "$USER" == "exedev" ]]; then
    activateConfiguration .#homeConfigurations.exedev.activationPackage
  else
    echo "Unsupported host or user: $HOST_NAME/$USER" >&2
    exit 1
  fi
)
RESTORE_NEEDED=0

# Update runtime environment
#
unset __ETC_PROFILE_NIX_SOURCED __HM_SESS_VARS_SOURCED
# shellcheck disable=SC1091  # path is only valid after Nix is installed
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

# Run GPU setup for nixpkgs/home-manager
#
if [[ "$OS" == "Linux" ]]; then
  sudo "$(command -v non-nixos-gpu-setup)"
fi

# Garbage collection
#
nix-collect-garbage -d
sudo find /nix/var/nix/gcroots -xtype l -exec rm -v {} +
nix store gc -v
nix store optimise -v

# Set up Hermes
#
if [[ "$HOST_NAME" == "kitsune" ]]; then
  # Install Hermes
  #
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

  # Install Mnemosyne
  #
  if [[ -d "$HOME/.hermes/mnemosyne-venv" ]]; then
    rm -rf "$HOME/.hermes/mnemosyne-venv"
  fi
  uv venv --python 3.14 "$HOME/.hermes/mnemosyne-venv"
  (
    cd "$HOME/.hermes/mnemosyne-venv"
    uv pip install --prerelease=explicit "mnemosyne-memory[embeddings]>=4.0.0b5" "mnemosyne-hermes"
    uv run mnemosyne-hermes --hermes-home "$HOME/.hermes" install --force --mode wrapper --python "$HOME/.hermes/mnemosyne-venv/bin/python"
  )

  # Install `xurl` search tool
  #
  curl -fsSL https://raw.githubusercontent.com/xdevplatform/xurl/main/install.sh | bash

  # Systemd setup
  #
  mkdir -p "$HOME/.hermes/hermes-relay"
  sudo loginctl enable-linger "$USER"

  # Link the skills installed into the Nix profile (see
  # bundles/opencode/pkgs) into Hermes' skills directory. The links point
  # at the profile path rather than the Nix store, so later home-manager
  # switches update the targets atomically.
  #
  mkdir -p "$HOME"/.hermes/skills
  for SKILL_SOURCE in "$HOME"/.nix-profile/share/hermes/skills/*; do
    if [[ ! -d "$SKILL_SOURCE" ]]; then
      continue
    fi
    SKILL_NAME="$(basename "$SKILL_SOURCE")"
    SKILL_TARGET="$HOME/.hermes/skills/$SKILL_NAME"
    # Never clobber a real directory (e.g. a skill Hermes installed
    # itself); only replace links created by an earlier run of this loop.
    #
    if [[ -e "$SKILL_TARGET" ]] && [[ ! -L "$SKILL_TARGET" ]]; then
      echo "WARNING: $SKILL_TARGET exists and is not a symlink; skipping"
      continue
    fi
    ln -sfn "$SKILL_SOURCE" "$SKILL_TARGET"
  done

  # Add herdr skill to Hermes
  #
  if [[ -d "$HOME"/.nix-profile/share/skills/herdr ]]; then
    if [[ ! -e "$HOME"/.hermes/skills/herdr ]] || [[ -L "$HOME"/.hermes/skills/herdr ]]; then
      ln -sfn "$HOME"/.nix-profile/share/skills/herdr "$HOME"/.hermes/skills/herdr
    else
      echo "WARNING: $HOME/.hermes/skills/herdr exists and is not a symlink; skipping"
    fi
  fi

  # Set up OpenCode, if applicable
  #
  if [[ -d "$XDG_CONFIG_HOME"/opencode ]]; then
    herdr integration install opencode
  fi

  # Install Hermes completions and plugins, if applicable
  #
  writeCompletion() {
    local shell_name="$1"
    local target="$2"
    local temporary_file
    temporary_file="$(mktemp "''${target}.XXXXXX")"
    if hermes completion "$shell_name" >"$temporary_file"; then
      mv "$temporary_file" "$target"
    else
      rm -f "$temporary_file"
      return 1
    fi
  }

  if [[ -n "$(command -v hermes 2>/dev/null)" ]]; then
    if [[ -d "$HOME"/.hermes/skills/officecli ]]; then
      rm -rf "$HOME"/.hermes/skills/officecli
    fi
    officecli skill install
    if [[ -d "$HOME"/.claude/skills/officecli ]]; then
      rm -rf "$HOME"/.claude/skills/officecli
    fi
    herdr integration install hermes
    if [[ -d "$XDG_CONFIG_HOME"/bash ]]; then
      if [[ ! -d "$XDG_CONFIG_HOME"/bash/rc.d ]]; then
        mkdir -p "$XDG_CONFIG_HOME"/bash/rc.d
      fi
      writeCompletion bash "$XDG_CONFIG_HOME"/bash/rc.d/hermes-completion.sh
    fi
    if [[ -d "$XDG_CONFIG_HOME"/zsh ]]; then
      if [[ ! -d "$XDG_CONFIG_HOME"/zsh/rc.d ]]; then
        mkdir -p "$XDG_CONFIG_HOME"/zsh/rc.d
      fi
      writeCompletion zsh "$XDG_CONFIG_HOME"/zsh/rc.d/hermes-completion.zsh
    fi
    if [[ -d "$XDG_CONFIG_HOME"/fish ]]; then
      if [[ ! -d "$XDG_CONFIG_HOME"/fish/completions ]]; then
        mkdir -p "$XDG_CONFIG_HOME"/fish/completions
      fi
      writeCompletion fish "$XDG_CONFIG_HOME"/fish/completions/hermes.fish
    fi

    hermes plugins enable browser-browser-use
    hermes plugins enable image_gen/openai
    hermes plugins enable image_gen/xai
    hermes plugins enable web-exa
    hermes plugins enable video_gen/xai
    hermes plugins enable web-xai

    hermes plugins install Codename-11/hermes-relay/plugin --enable
  fi
fi

# Make sure that SSH is set up on macOS and kitsune.exe.xyz
#
if [[ "$OS" == "Darwin" ]] || [[ "$HOST_NAME" == "kitsune" ]]; then
  mkdir -p "$HOME/.ssh"
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

# Create a code repository archive on macOS
#
if [[ "$OS" == "Darwin" ]]; then
  mkdir -p "$HOME"/Projects
elif [[ "$HOST_NAME" == "kitsune" ]]; then
  mkdir -p "$HOME"/workspace
else
  mkdir -p "$HOME"/src
fi

# A reboot is STRONGLY recommended
#
echo ""
echo "Configuration complete!"
echo ""
echo "You MUST restart the system NOW."
