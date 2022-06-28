#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications from system repos.
#
apk add \
bash \
curl \
drill \
ffmpeg \
git \
graphicsmagick \
libwebp-tools \
mandoc \
man-pages \
nano \
openssl \
p7zip \
youtube-dl

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/profile                    $HOME/.profile
cp $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh

chmod +x $HOME/.local/bin/*

# Restore select git repos.
#
mkdir $HOME/Repos
(
	cd $HOME/Repos
	git clone https://github.com/necopinus/dotfiles.git
)
