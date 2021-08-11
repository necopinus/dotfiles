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

# Add the "official" OneDrive client for Linux repository.
#
# This is necessary because the version in the Debian (and derivatives)
# repos is chronically out-of-date. See:
#
#     https://github.com/abraunegg/onedrive/blob/master/docs/ubuntu-package-install.md
#
(
	TEMPDIR=$(mktemp -d)
	cd $TEMPDIR
	curl -L -O https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/Debian_10/Release.key
	gpg --no-default-keyring --keyring ./temp-keyring.gpg --import Release.key
	gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output onedrive.gpg
	sudo mkdir -p /usr/local/share/keyrings
	sudo mv onedrive.gpg /usr/local/share/keyrings/onedrive.gpg
	sudo chown root:root /usr/local/share/keyrings/onedrive.gpg
	sudo chmod 644 /usr/local/share/keyrings/onedrive.gpg
	cd /tmp
	rm -rf $TEMPDIR
)
echo "deb [signed-by=/usr/local/share/keyrings/onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/Debian_10/ ./" | sudo tee -a /etc/apt/sources.list.d/onedrive.list

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Remove /usr/bin/python2 -> /usr/bin/python symlink (and eliminate
# associated login warning). See:
#
#     https://www.kali.org/docs/general-use/python3-transition/
#
sudo apt remove --purge --autoremove python-is-python2

# Install new applications.
#
sudo apt install \
code-oss \
dconf-editor \
exfatprogs \
flatpak \
fonts-noto \
golang \
graphicsmagick \
handbrake \
htop \
jhead \
jq \
keepassxc \
libpcsclite-dev \
offlineimap \
onedrive \
optipng \
qalc \
rclone \
sound-juicer \
soundconverter \
swig \
youtube-dl

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
source $CONFIG_PATH/user/local/bin/update-hydroxide.sh
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh
source $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh

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
cp $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh        $HOME/.local/bin/update-yubikey-manager.sh

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
