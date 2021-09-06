#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Make sure that locale is properly set.
#
sudo dpkg-reconfigure locales

# Make sure that the timezone is properly set.
#
sudo dpkg-reconfigure tzdata

# Allow ports for "local" Hugo and Jekyll development.
#
sudo ufw allow in on usb0 from 10.55.0.0/29 to 10.55.0.1 port 1313 proto tcp
sudo ufw allow in on usb0 from 10.55.0.0/29 to 10.55.0.1 port 4000 proto tcp

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Remove /usr/bin/python2 -> /usr/bin/python symlink (and eliminate
# associated login warning). See:
#
#     https://www.kali.org/docs/general-use/python3-transition/
#
sudo apt remove --purge --autoremove python-is-python2

# Remove colord, as I don't use this system for image editing or
# watching movies, and it generates annoying prompts when running
# XFCE over XRDP.
#
sudo apt purge --autoremove --purge colord

# Install new applications.
#
sudo apt install \
code-oss \
dconf-editor \
exfat-utils \
flatpak \
fonts-noto \
golang \
graphicsmagick \
handbrake \
htop \
jhead \
jq \
keepassxc \
optipng \
qalc \
sound-juicer \
soundconverter \
youtube-dl \
yubikey-manager \
yubikey-personalization-gui

# The above packages supercede some installed packages, so we do some
# additional cleanup here.
#
sudo apt autoremove --purge --autoremove

# Setup Flatpak and install Obsidian.
#
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub md.obsidian.Obsidian

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-keybase.sh
source $CONFIG_PATH/user/local/bin/update-rclone.sh
source $CONFIG_PATH/user/local/bin/update-rclonesync.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings show-warning     false
gsettings set org.gnome.sound-juicer         audio-profile    "audio/mpeg"
gsettings set org.gnome.sound-juicer         file-pattern     "%at - %dn - %ta - %tt"
gsettings set org.gnome.sound-juicer         path-pattern     "%at"
gsettings set org.gtk.Settings.FileChooser   clock-format     "24h"
gsettings set org.soundconverter             mp3-vbr-quality  0
gsettings set org.soundconverter             output-mime-type "audio/mpeg"

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                        $HOME/.bash_aliases
cp $CONFIG_PATH/user/gitconfig                           $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                             $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup-cloud.sh           $HOME/.local/bin/backup-cloud.sh
cp $CONFIG_PATH/user/local/bin/backup-local.sh           $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/user/local/bin/update-full.sh            $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-keybase.sh         $HOME/.local/bin/update-keybase.sh
cp $CONFIG_PATH/user/local/bin/update-rclone.sh          $HOME/.local/bin/update-rclone.sh
cp $CONFIG_PATH/user/local/bin/update-rclonesync.sh      $HOME/.local/bin/update-rclonesync.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh          $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/tmux.conf                           $HOME/.tmux.conf

chmod 755 $HOME/.local/bin/*

# Finish up part 1.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""

sudo reboot
