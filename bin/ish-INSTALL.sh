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
build-base \
curl \
dos2unix \
drill \
ffmpeg \
go \
graphicsmagick \
graphviz \
jq \
mandoc \
man-pages \
nano \
optipng \
p7zip \
poppler-utils \
py3-beautifulsoup4 \
py3-pip \
py3-virtualenv \
ruby-bundler \
ruby-dev \
ruby-json \
sqlite \
tmux \
youtube-dl

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/profile                        $HOME/.profile
cp $CONFIG_PATH/user/local/bin/update-full.sh       $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh $HOME/.local/bin/update-youtube-dl.sh

chmod 755 $HOME/.local/bin/*

# Set up iOS mounts.
#
mkdir Code
mount -t ios none Code

mkdir Downloads
mount -t ios none Downloads

mkdir Obsidian
mount -t ios none Obsidian
