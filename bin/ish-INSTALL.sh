#!/usr/bin/env ash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="`realpath "$0"`"
CONFIG_PATH="`dirname "$SCRIPT_PATH"`/../"

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications from system repos.
#
apk add \
dos2unix \
drill \
ffmpeg \
go \
graphicsmagick \
graphviz \
jq \
man-db-doc \
nano \
nodejs-current \
optipng \
p7zip \
poppler-utils \
py3-pip \
py3-virtualenv \
ruby-bundler \
youtube-dl

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/inputrc                        $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/update-full.sh       $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh $HOME/.local/bin/update-youtube-dl.sh

chmod 755 $HOME/.local/bin/*
