#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../user/"

# 1991 called. They want their disabled-by-default firewall back.
#
sudo ufw enable

# Add the Brave repository.
#
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Add the Google Endpoint Verification repository (needed for work).
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/google.gpg add -
echo "deb https://packages.cloud.google.com/apt endpoint-verification main" | sudo tee -a /etc/apt/sources.list.d/endpoint-verification.list

# Add the NodeSource repository.
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
sudo apt install apt-transport-https
source $CONFIG_PATH/local/bin/update-system.sh

# Cleanup unneeded software.
#
sudo apt purge --autoremove --purge \
firefox \
firefox-locale-ar \
firefox-locale-de \
firefox-locale-en \
firefox-locale-es \
firefox-locale-fr \
firefox-locale-it \
firefox-locale-ja \
firefox-locale-pt \
firefox-locale-ru \
firefox-locale-zh-hans \
firefox-locale-zh-hant \
geary \
gnome-calculator \
gnome-calendar \
gnome-contacts \
gnome-font-viewer \
gucharmap \
libreoffice-core \
simple-scan \
totem

# Clean up random files/directories.
#
sudo rm -rf /usr/share/fonts/truetype/libreoffice

# Install new applications.
#
sudo apt install \
brave-browser \
bundler \
code \
dconf-editor \
dino-im \
discord \
dos2unix \
endpoint-verification \
exfatprogs \
fonts-cascadia-code \
fonts-croscore \
fonts-crosextra-caladea \
fonts-crosextra-carlito \
fonts-noto \
fonts-roboto \
gnome-shell-extension-bluetooth-quick-connect \
gnome-shell-extension-dashtodock \
golang \
google-chrome-stable \
graphicsmagick \
graphviz \
ibus-typing-booster \
jhead \
nodejs \
offlineimap \
onedrive \
optipng \
p7zip-full \
qalc \
vdirsyncer \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
yubikey-manager

flatpak install --user flathub com.github.bleakgrey.tootle
flatpak install --user flathub com.toggl.TogglDesktop
flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub fr.handbrake.ghb
flatpak install --user flathub io.github.quodlibet.ExFalso
flatpak install --user flathub io.github.quodlibet.QuodLibet
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.gnome.Fractal
flatpak install --user flathub org.gnome.Maps
flatpak install --user flathub org.gnome.Shotwell
flatpak install --user flathub org.gnome.SoundJuicer
flatpak install --user flathub org.inkscape.Inkscape
flatpak install --user flathub org.jitsi.jitsi-meet
flatpak install --user flathub org.keepassxc.KeePassXC
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.stellarium.Stellarium
flatpak install --user flathub org.videolan.VLC
flatpak install --user flathub uk.co.ibboard.cawbird
flatpak install --user flathub us.zoom.Zoom

# Keybase, annoyingly, requires us to download a .deb file to install.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -O https://prerelease.keybase.io/keybase_amd64.deb
	sudo apt install ./keybase_amd64.deb
)
rm -rf "$BUILD_DIR"

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/local/bin/update-gam.sh
source $CONFIG_PATH/local/bin/update-hydroxide.sh
source $CONFIG_PATH/local/bin/update-ykman.sh

# Apply application settings, when possible.
#
# FIXME: How can I do this for flatpak apps?
#
gsettings set ca.desrt.dconf-editor.Settings             show-warning                 false
gsettings set org.freedesktop.ibus.engine.typing-booster dictionary                   "en_US"
gsettings set org.freedesktop.ibus.engine.typing-booster emojipredictions             true
gsettings set org.freedesktop.ibus.engine.typing-booster inputmethod                  "NoIME"
gsettings set org.gnome.desktop.input-sources            mru-sources                  "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.input-sources            sources                      "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.interface                clock-format                 "24h"
gsettings set org.gnome.desktop.interface                gtk-im-module                "ibus"
gsettings set org.gnome.desktop.media-handling           autorun-never                true
gsettings set org.gnome.desktop.peripherals.touchpad     natural-scroll               true
gsettings set org.gnome.desktop.privacy                  recent-files-max-age         30
gsettings set org.gnome.desktop.privacy                  remove-old-temp-files        true
gsettings set org.gnome.desktop.privacy                  remove-old-trash-files       true
gsettings set org.gnome.desktop.search-providers         enabled                      "['org.gnome.Weather.desktop','io.github.quodlibet.QuodLibet.desktop']"
gsettings set org.gnome.desktop.wm.keybindings           switch-applications          "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows               "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows-backward      "['<Shift><Alt>Tab']"
gsettings set org.gnome.gnome-system-monitor             solaris-mode                 false
gsettings set org.gnome.nautilus.list-view               use-tree-view                true
gsettings set org.gnome.nautilus.preferences             default-folder-viewer        "list-view"
gsettings set org.gnome.settings-daemon.plugins.color    night-light-enabled          true
gsettings set org.gnome.settings-daemon.plugins.color    night-light-temperature      3700
gsettings set org.gnome.shell                            enabled-extensions           "['alt-tab-raise-first-window@system76.com','always-show-workspaces@system76.com','ding@rastersoft.com','pop-shell@system76.com','pop-shop-details@system76.com','system76-power@system76.com','ubuntu-appindicators@ubuntu.com','bluetooth-quick-connect@bjarosze.gmail.com','dash-to-dock@micxgx.gmail.com']"
gsettings set org.gnome.shell.extensions.dash-to-dock    dash-max-icon-size           64
gsettings set org.gnome.shell.extensions.dash-to-dock    dock-position                "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock    preferred-monitor            0
gsettings set org.gnome.shell.extensions.dash-to-dock    show-mounts                  false
gsettings set org.gnome.shell.extensions.dash-to-dock    show-trash                   false
gsettings set org.gnome.shell.extensions.dash-to-dock    transparency-mode            "FIXED"
gsettings set org.gnome.shell.weather                    automatic-location           true
gsettings set org.gnome.system.location                  enabled                      true
gsettings set org.gnome.Weather                          automatic-location           true
gsettings set org.gtk.Settings.FileChooser               clock-format                 "24h"

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.cache/onedrive
mkdir -p $HOME/.config/systemd/user
mkdir -p $HOME/.config/onedrive/{DelphiStrategy,EcoPunk}
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications

cp $CONFIG_PATH/bash_aliases                           $HOME/.bash_aliases
cp $CONFIG_PATH/config/onedrive/DelphiStrategy/config  $HOME/.config/onedrive/DelphiStrategy/config
cp $CONFIG_PATH/config/onedrive/EcoPunk/config         $HOME/.config/onedrive/EcoPunk/config
cp $CONFIG_PATH/config/systemd/user/hydroxide.service  $HOME/.config/systemd/user/hydroxide.service
cp $CONFIG_PATH/config/systemd/user/onedrive@.service  $HOME/.config/systemd/user/onedrive@.service
cp $CONFIG_PATH/gitconfig                              $HOME/.gitconfig
cp $CONFIG_PATH/local/bin/backup-cloud.sh              $HOME/.local/bin/backup-cloud.sh
cp $CONFIG_PATH/local/bin/backup-local.sh              $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/local/bin/update-gam.sh                $HOME/.local/bin/update-gam.sh
cp $CONFIG_PATH/local/bin/update-hydroxide.sh          $HOME/.local/bin/update-hydroxide.sh
cp $CONFIG_PATH/local/bin/update-system.sh             $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/local/bin/update-ykman.sh              $HOME/.local/bin/update-ykman.sh
cp $CONFIG_PATH/local/share/applications/ykman.desktop $HOME/.local/share/applications/ykman.desktop

chmod 755 $HOME/.local/bin/*

# Create a stub ~/.config/backup-password file. The actual value for
# "XXX" will need to be filled in from KeePassXC.
#
echo 'BACKUP_PASSWORD="XXX"' > $HOME/.config/backup-password
chmod 700 $HOME/.config
chmod 600 $HOME/.config/backup-password

# Disable the VirtualBox web service. We don't need it, and it just
# likes to fail and make systemd complain anyway.
#
sudo systemctl disable vboxweb.service

# Finish up part 1.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""
sudo reboot
