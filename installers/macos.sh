#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Get Xcode and associated tools installed.
#
xcode-select --install
read -p "Press any key once Xcode has finished installing... " -n1 -s

# Install Homebrew. See:
#
#     https://brew.sh/
#
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to our path.
#
eval "$(/opt/homebrew/bin/brew shellenv)"

# Disable Homebrew analytics.
#
brew analytics off

# Add the cask-drivers tap to Homebrew.
#
brew tap homebrew/cask-drivers

# Install new applications.
#
brew install \
brave-browser \
coreutils \
diffutils \
discord \
expect \
ffmpeg \
free-gpgmail \
gimp \
gpg-suite-no-mail \
graphicsmagick \
graphviz \
handbrake \
insync \
jq \
keepassxc \
keybase \
lagrange \
libqalculate \
logitech-options \
logitech-unifying \
microsoft-excel \
microsoft-powerpoint \
microsoft-remote-desktop \
microsoft-word \
node \
obsidian \
optipng \
parallels \
poppler \
protonvpn \
radicle-upstream \
rust \
signal \
slack \
virtualenv \
visual-studio-code \
webp \
youtube-dl \
zoom

# Install a better Zsh configuration.
#
curl -L -o $HOME/.zshrc "https://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/zsh/zshrc;hb=HEAD"
curl -L -o $HOME/.zshrc.local "https://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/skel/.zshrc;hb=HEAD"

# Add additional Homebrew paths.
#
cat >> $HOME/.zshrc.local << EOF

# Add Homebrew to the shell's PATH.
#
eval "\$(/opt/homebrew/bin/brew shellenv)"

# Additional paths.
#
export PATH="\$HOME/.local/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/jpeg-turbo/bin:\$PATH"
EOF

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin $HOME/.ssh

cp $CONFIG_PATH/user/local/bin/update-full.sh   $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/ssh/config                 $HOME/.ssh/config

chmod 755 $HOME/.local/bin/*
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*

# Restore all git repos.
#
(
	git config --global user.name "Nathan Acks"
	git config --global user.email nathan.acks@cardboard-iguana.com
#	git config --global user.signingKey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	git config --global commit.gpgSign true
	git config --global pull.rebase false
	cd $HOME/Documents
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yakcollective
	git clone git@github.com:necopinus/cardboard-iguana.com.git
	git clone git@github.com:necopinus/chateaumaxmin.info.git
	git clone git@github.com:necopinus/delphi-strategy.com.git
	git clone git@github.com:necopinus/digital-orrery.com.git
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@github.com:necopinus/ecopunk.info.git
	git clone git@github.com:necopinus/ellen-and-nathan.info.git
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	git clone git@github.com:The-Yak-Collective/lunchtime-tickets.git
	git clone git@github.com:necopinus/necopinus.xyz.git
	git clone git@github.com:The-Yak-Collective/onboarding_robot.git
	git clone git@github.com:The-Yak-Collective/project_ui.git
	git clone git@github.com:necopinus/resume.git
	git clone git@github.com:necopinus/website-theme.git
	git clone git@github.com:The-Yak-Collective/yakcollective.git
	git clone git@github.com:necopinus/zibaldone.git
)
