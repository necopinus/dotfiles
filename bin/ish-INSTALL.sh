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
dos2unix \
drill \
ffmpeg \
go \
graphicsmagick \
graphviz \
jq \
man-db-doc \
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

# Pull all git repos (that make sense).
#
mkdir -p $HOME/Code
(
	cd $HOME/Code
	git clone https://github.com/The-Yak-Collective/onboarding_robot.git
	mv onboarding_robot automation-onboarding-robot
	git clone https://github.com/The-Yak-Collective/project_ui.git
	mv project_ui automation-project-ui
	git clone https://github.com/The-Yak-Collective/infrastructure-map.git
	mv infrastructure-map doc-infrastructure-map
	#git clone https://github.com/necopinus/dotfiles.git
	git clone https://github.com/The-Yak-Collective/yakcollective.git
	mv yakcollective website-yakcollective.org
)
