#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Install prerequisites.
#
sudo apt install apt-transport-https software-properties-common
sudo mkdir -p /usr/local/share/keyrings

# Add the NodeSource repository. See:
#
#     https://node.dev/node-binary
#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee /usr/local/share/keyrings/nodesource.gpg
echo "deb     [signed-by=/usr/local/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x buster main" | sudo tee    /etc/apt/sources.list.d/nodesource.list
echo "deb-src [signed-by=/usr/local/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x buster main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list

# Add Google repos. See:
#
#     https://cloud.google.com/sdk/docs/install#deb
#
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/local/share/keyrings/cloud.google.gpg add -
echo "deb [signed-by=/usr/local/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications from system repos.
#
sudo apt install \
dnsutils \
ffmpeg \
fonts-noto \
google-cloud-sdk \
graphicsmagick \
htop \
nano \
nodejs \
poppler-utils \
qalc \
rsync \
seahorse

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-gam.sh
source $CONFIG_PATH/user/local/bin/update-obsidian.sh
source $CONFIG_PATH/user/local/bin/update-zoom.sh

# Download and install Obsidian's (Flatpak) icon.
#
mkdir -p $HOME/.local/share/icons
(
	cd $HOME/.local/share/icons
	curl -L -O https://raw.githubusercontent.com/flathub/md.obsidian.Obsidian/master/md.obsidian.Obsidian.png
)

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications

cp $CONFIG_PATH/user/bash_aliases                                          $HOME/.bash_aliases
cp $CONFIG_PATH/user/gitconfig                                             $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                                               $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/update-full.sh                              $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-gam.sh                               $HOME/.local/bin/update-gam.sh
cp $CONFIG_PATH/user/local/bin/update-obsidian.sh                          $HOME/.local/bin/update-obsidian.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh                            $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-zoom.sh                              $HOME/.local/bin/update-zoom.sh
cp $CONFIG_PATH/user/local/share/applications/md.obsidian.Obsidian.desktop $HOME/.local/share/applications/md.obsidian.Obsidian.desktop

chmod 755 $HOME/.local/bin/*

# Fix the Obsidian .desktop file paths, because Chrome OS can be kind
# of oblivious to files installed in ~/.local.
#
sed -i -e "s#^Exec=obsidian %u$#Exec=$HOME/.local/bin/obsidian %u#;s#^Icon=md\.obsidian\.Obsidian$#Icon=$HOME/.local/share/icons/md.obsidian.Obsidian.png#" $HOME/.local/share/applications/md.obsidian.Obsidian.desktop

# Copy GAM data into Crostini (since GAM seems to have locking problems
# when accessing this directly from the Google Drive share).
#
# We copy this back on each login to try to ensure a good backup.
#
# NOTE: Google Drive/My Drive/gam needs to be shared with Linux (and
# preferably marked for offline use)!
#
rsync -av --delete --force --human-readable --no-group --progress /mnt/chromeos/GoogleDrive/MyDrive/gam/ $HOME/.gam/
chown -R ${USER}.${USER} $HOME/.gam
chmod 700 $HOME/.gam
chmod 600 $HOME/.gam/*

# Restore all git repos.
#
mkdir -p $HOME/Code
(
	git config --global user.email nathan.acks@publicinterestnetwork.org
	git config --global user.signingkey "$(gpg --list-keys nathan.acks@publicinterestnetwork.org | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	cd $HOME/Code
	git clone https://github.com/keeweb/keeweb.git
	mv keeweb app-keeweb
	git clone git@bitbucket.org:tpin-it-security/keeweb-overlay.git
	mv keeweb-overlay app-keeweb-overlay
	git clone git@bitbucket.org:tpin-it-security/assets-okta.git
	git clone git@bitbucket.org:tpin-it-security/computer-setup.git
	mv computer-setup automation-computer-setup
	git clone https://github.com/necopinus/dotfiles.git
)

# Create "Downloads" symlink.
#
ln -s /mnt/chromeos/MyFiles/Downloads $HOME/Downloads