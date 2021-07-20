#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Install prerequisites.
#
sudo apt install apt-transport-https software-properties-common

# Add the NodeSource repository. See:
#
#     https://node.dev/node-binary
#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/nodesource.gpg add -
sudo apt-add-repository https://deb.nodesource.com/node_14.x

# Add Microsoft repos. See:
#
#     https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux#debian-10
#
curl -O https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
sudo apt install ./packages-microsoft-prod.deb
rm -f ./packages-microsoft-prod.deb

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications from system repos.
#
sudo apt install \
bundler \
dconf-editor \
dos2unix \
flatpak \
fonts-noto \
golang \
graphicsmagick \
graphviz \
jhead \
jq \
nano \
nodejs \
optipng \
p7zip-full \
powershell \
python3-bs4 \
qalc \
rsync \
seahorse \
virtualenv

# Install VS Code.
#
curl -L -J -O "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo apt install ./code_*.deb
rm -f ./code_*.deb

# Setup Flatpak and install Obsidian.
#
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub md.obsidian.Obsidian

# Flatpak cursor scaling fix. See:
#
#     https://github.com/flatpak/flatpak/issues/740#issuecomment-721643798
#
# But why does this work?!?
#
mkdir -p $HOME/.icons/default/cursors
cp -aprf /usr/share/icons/Adwaita/cursors/* $HOME/.icons/default/cursors/

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-gam.sh
source $CONFIG_PATH/user/local/bin/update-zoom.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings show-warning false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases               $HOME/.bash_aliases
cp $CONFIG_PATH/user/bash_logout                $HOME/.bash_logout
cp $CONFIG_PATH/user/gitconfig                  $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                    $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/update-gam.sh    $HOME/.local/bin/update-gam.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-zoom.sh   $HOME/.local/bin/update-zoom.sh

chmod 755 $HOME/.local/bin/*

# Restore all git repos.
#
mkdir -p $HOME/code
(
	git config --global user.email nathan.acks@publicinterestnetwork.org
	git config --global user.signingkey "$(gpg --list-keys nathan.acks@publicinterestnetwork.org | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	cd $HOME/code
	git clone https://github.com/keeweb/keeweb.git
	mv keeweb app-keeweb
	git clone git@bitbucket.org:tpin-it-security/keeweb-overlay.git
	mv keeweb-overlay app-keeweb-overlay
	git clone git@bitbucket.org:tpin-it-security/assets-okta.git
	git clone git@bitbucket.org:tpin-it-security/automation-it-lifecycle.git
	git clone git@bitbucket.org:tpin-it-security/computer-setup.git
	mv computer-setup automation-computer-setup
)
