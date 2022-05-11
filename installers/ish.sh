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
curl \
drill \
ffmpeg \
graphicsmagick \
libwebp-tools \
mandoc \
man-pages \
nano \
openssl \
p7zip

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/profile                    $HOME/.profile
cp $CONFIG_PATH/user/local/bin/update-full.sh   $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh

chmod +x $HOME/.local/bin/*
