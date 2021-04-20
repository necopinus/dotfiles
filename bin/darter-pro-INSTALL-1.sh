#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

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
source $CONFIG_PATH/user/local/bin/update-system.sh

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
gedit \
gnome-calculator \
gnome-calendar \
gnome-contacts \
gnome-font-viewer \
gnome-weather \
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
discord \
dos2unix \
endpoint-verification \
exfatprogs \
ffmpeg \
git-lfs \
gnome-shell-extension-bluetooth-quick-connect \
gnome-shell-extension-dashtodock \
gnome-tweaks \
golang \
google-chrome-stable \
graphicsmagick \
graphviz \
grub-pc \
ibus-typing-booster \
jhead \
libgtk-3-dev \
mpack \
nodejs \
offlineimap \
onedrive \
optipng \
p7zip-full \
python3-wxgtk4.0 \
qalc \
vdirsyncer \
vim \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
wimtools \
xdotool \
yubikey-manager

flatpak install --user flathub com.toggl.TogglDesktop
flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub fr.handbrake.ghb
flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.gnome.SoundJuicer
flatpak install --user flathub org.keepassxc.KeePassXC
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.videolan.VLC

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-zoom.sh
source $CONFIG_PATH/user/local/bin/update-gam.sh
source $CONFIG_PATH/user/local/bin/update-hydroxide.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings             show-warning                 false
gsettings set org.freedesktop.ibus.engine.typing-booster dictionary                   "en_US"
gsettings set org.freedesktop.ibus.engine.typing-booster emojipredictions             true
gsettings set org.freedesktop.ibus.engine.typing-booster inputmethod                  "NoIME"
gsettings set org.gnome.desktop.input-sources            mru-sources                  "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.input-sources            sources                      "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.interface                clock-format                 "24h"
gsettings set org.gnome.desktop.interface                document-font-name           "Roboto Slab 13"
gsettings set org.gnome.desktop.interface                font-name                    "Fira Sans Semi-Light 13"
gsettings set org.gnome.desktop.interface                monospace-font-name          "Fira Mono 13"
gsettings set org.gnome.desktop.interface                gtk-im-module                "ibus"
gsettings set org.gnome.desktop.media-handling           autorun-never                true
gsettings set org.gnome.desktop.peripherals.touchpad     natural-scroll               true
gsettings set org.gnome.desktop.privacy                  recent-files-max-age         30
gsettings set org.gnome.desktop.privacy                  remove-old-temp-files        true
gsettings set org.gnome.desktop.privacy                  remove-old-trash-files       true
gsettings set org.gnome.desktop.search-providers         enabled                      "['io.github.quodlibet.QuodLibet.desktop']"
gsettings set org.gnome.desktop.wm.keybindings           switch-applications          "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows               "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows-backward      "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.preferences           titlebar-font                "Fira Sans Semi-Bold 13"
gsettings set org.gnome.gnome-system-monitor             solaris-mode                 false
gsettings set org.gnome.nautilus.list-view               use-tree-view                true
gsettings set org.gnome.nautilus.preferences             default-folder-viewer        "list-view"
gsettings set org.gnome.settings-daemon.plugins.color    night-light-enabled          true
gsettings set org.gnome.settings-daemon.plugins.color    night-light-temperature      3700
gsettings set org.gnome.shell                            enabled-extensions           "['alt-tab-raise-first-window@system76.com','always-show-workspaces@system76.com','ding@rastersoft.com','pop-shell@system76.com','pop-shop-details@system76.com','system76-power@system76.com','ubuntu-appindicators@ubuntu.com','bluetooth-quick-connect@bjarosze.gmail.com','dash-to-dock@micxgx.gmail.com']"
gsettings set org.gnome.shell.extensions.dash-to-dock    dash-max-icon-size           64
gsettings set org.gnome.shell.extensions.dash-to-dock    dock-position                "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock    multi-monitor                true
gsettings set org.gnome.shell.extensions.dash-to-dock    preferred-monitor            0
gsettings set org.gnome.shell.extensions.dash-to-dock    shortcut                     "['<Super><Shift>a']"
gsettings set org.gnome.shell.extensions.dash-to-dock    shortcut-text                "<Super><Shift>a"
gsettings set org.gnome.shell.extensions.dash-to-dock    show-mounts                  false
gsettings set org.gnome.shell.extensions.dash-to-dock    show-trash                   false
gsettings set org.gnome.shell.extensions.dash-to-dock    transparency-mode            "FIXED"
gsettings set org.gnome.shell.extensions.pop-shell       active-hint                  true
gsettings set org.gnome.shell.extensions.pop-shell       gap-inner                    0
gsettings set org.gnome.shell.extensions.pop-shell       gap-outer                    0
gsettings set org.gnome.shell.extensions.pop-shell       show-title                   false
gsettings set org.gnome.shell.extensions.pop-shell       tile-by-default              true
gsettings set org.gnome.shell.window-switcher            current-workspace-only       false
gsettings set org.gnome.system.location                  enabled                      true
gsettings set org.gtk.Settings.FileChooser               clock-format                 "24h"

# Apply settings for relocatable schemas.
#
gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/gnome-power-panel/ enable false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.cache/onedrive
mkdir -p $HOME/.config/systemd/user
mkdir -p $HOME/.config/onedrive/{DelphiStrategy,EcoPunk}
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                          $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/onedrive/DelphiStrategy/config $HOME/.config/onedrive/DelphiStrategy/config
cp $CONFIG_PATH/user/config/onedrive/EcoPunk/config        $HOME/.config/onedrive/EcoPunk/config
cp $CONFIG_PATH/user/config/systemd/user/hydroxide.service $HOME/.config/systemd/user/hydroxide.service
cp $CONFIG_PATH/user/config/systemd/user/onedrive@.service $HOME/.config/systemd/user/onedrive@.service
cp $CONFIG_PATH/user/gitconfig                             $HOME/.gitconfig
cp $CONFIG_PATH/user/local/bin/backup-cloud.sh             $HOME/.local/bin/backup-cloud.sh
cp $CONFIG_PATH/user/local/bin/backup-local.sh             $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/user/local/bin/backup-obsidian.sh          $HOME/.local/bin/backup-obsidian.sh
cp $CONFIG_PATH/user/local/bin/update-gam.sh               $HOME/.local/bin/update-gam.sh
cp $CONFIG_PATH/user/local/bin/update-hydroxide.sh         $HOME/.local/bin/update-hydroxide.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh            $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-zoom.sh              $HOME/.local/bin/update-zoom.sh
cp $CONFIG_PATH/user/local/bin/zibaldone-new-assets.sh     $HOME/.local/bin/zibaldone-new-assets.sh
cp $CONFIG_PATH/user/local/bin/zibaldone-optimize-file.sh  $HOME/.local/bin/zibaldone-optimize-file.sh

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
