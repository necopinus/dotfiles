#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Install prerequisites.
#
sudo apt install apt-transport-https

# Add the Google Endpoint Verification repository (needed for work).
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/google.gpg add -
echo "deb https://packages.cloud.google.com/apt endpoint-verification main" | sudo tee -a /etc/apt/sources.list.d/endpoint-verification.list

# Add the NodeSource repository. See:
#
#     https://node.dev/node-binary
#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/nodesource.gpg add -
sudo apt-add-repository https://deb.nodesource.com/node_14.x

# Add the "official" OneDrive client for Linux repository.
#
# This is necessary because the version in the Ubuntu (and derivatives)
# repos is chronically out-of-date. See:
#
#     https://github.com/abraunegg/onedrive/blob/master/docs/INSTALL.md#installing-from-distribution-packages
#
sudo add-apt-repository ppa:yann1ck/onedrive

# Add the Yubico PPA, again because Ubuntu's repos are out-of-date.
#
sudo apt-add-repository ppa:yubico/stable

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications.
#
sudo apt install \
bundler \
code \
dconf-editor \
discord \
dos2unix \
endpoint-verification \
exfatprogs \
fonts-noto \
golang \
google-chrome-stable \
graphicsmagick \
graphviz \
grub-pc \
handbrake \
htop \
ibus-typing-booster \
jhead \
jq \
nodejs \
offlineimap \
onedrive \
optipng \
p7zip-full \
python3-bs4 \
qalc \
sound-juicer \
soundconverter \
vim \
youtube-dl \
yubikey-manager

flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.keepassxc.KeePassXC

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-hydroxide.sh
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings             show-warning     false
gsettings set org.freedesktop.ibus.engine.typing-booster dictionary       "en_US"
gsettings set org.freedesktop.ibus.engine.typing-booster emojipredictions true
gsettings set org.freedesktop.ibus.engine.typing-booster inputmethod      "NoIME"
gsettings set org.gnome.desktop.input-sources            mru-sources      "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.input-sources            sources          "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.sound-juicer                     audio-profile    "audio/mpeg"
gsettings set org.gnome.sound-juicer                     file-pattern     "%at - %dn - %ta - %tt"
gsettings set org.gnome.sound-juicer                     path-pattern     "%at"
gsettings set org.gtk.Settings.FileChooser               clock-format     "24h"
gsettings set org.soundconverter                         mp3-vbr-quality  0
gsettings set org.soundconverter                         output-mime-type "audio/mpeg"

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.cache/onedrive
mkdir -p $HOME/.config/systemd/user
mkdir -p $HOME/.config/onedrive
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                               $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/onedrive/config                     $HOME/.config/onedrive/config
cp $CONFIG_PATH/user/config/systemd/user/hydroxide.service      $HOME/.config/systemd/user/hydroxide.service
cp $CONFIG_PATH/user/config/systemd/user/onedrive.service       $HOME/.config/systemd/user/onedrive.service
cp $CONFIG_PATH/user/gitconfig                                  $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                                    $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup-cloud.sh                  $HOME/.local/bin/backup-cloud.sh
cp $CONFIG_PATH/user/local/bin/backup-local.sh                  $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/user/local/bin/update-hydroxide.sh              $HOME/.local/bin/update-hydroxide.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh                 $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh             $HOME/.local/bin/update-youtube-dl.sh

chmod 755 $HOME/.local/bin/*

# Create a stub ~/.config/backup-password file. The actual value for
# "XXX" will need to be filled in from KeePassXC.
#
echo 'BACKUP_PASSWORD="XXX"' > $HOME/.config/backup-password
chmod 700 $HOME/.config
chmod 600 $HOME/.config/backup-password

# Finish up part 1.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""
sudo reboot
