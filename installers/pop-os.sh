#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# 1991 called. They want their disabled-by-default firewall back.
#
sudo ufw enable
sudo ufw default deny

# Install prerequisites.
#
sudo apt install apt-transport-https
sudo mkdir -p /usr/local/share/keyrings

# Add Brave repo. See:
#
#     https://brave.com/linux/
#
curl -L -O https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo mv brave-browser-archive-keyring.gpg /usr/local/share/keyrings/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/local/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Add ProtonVPN repo. See:
#
#     https://protonvpn.com/support/linux-ubuntu-vpn-setup/
#
curl -L -O https://protonvpn.com/download/protonvpn-stable-release_1.0.1-1_all.deb
sudo apt install ./protonvpn-stable-release_1.0.1-1_all.deb
rm -f ./protonvpn-stable-release_1.0.1-1_all.deb

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Cleanup unneeded software.
#
sudo apt purge --autoremove --purge \
baobab \
eog \
evince \
file-roller \
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
gnome-power-manager \
gnome-weather \
gucharmap \
libreoffice-common \
popsicle-gtk \
seahorse \
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
cmake \
exfatprogs \
expect \
fonts-noto \
gir1.2-appindicator3-0.1 \
gnome-screenshot \
gobuster \
graphicsmagick \
graphviz \
grub-pc \
htop \
jq \
libjpeg-turbo-progs \
libreadline-dev \
nmap \
npm \
optipng \
protonvpn \
python3-bs4 \
python3-openssl \
python3-pip \
qalc \
rust-all \
solaar \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
virtualenv \
webp \
youtube-dl

flatpak install --user flathub ca.desrt.dconf-editor
flatpak install --user flathub com.discordapp.Discord
flatpak install --user flathub com.slack.Slack
flatpak install --user flathub com.visualstudio.code
flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.gnome.eog
flatpak install --user flathub org.gnome.Evince
flatpak install --user flathub org.gnome.FileRoller
flatpak install --user flathub org.gnome.seahorse.Application
flatpak install --user flathub org.keepassxc.KeePassXC
flatpak install --user flathub org.libreoffice.LibreOffice
flatpak install --user flathub org.mozilla.firefox
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.videolan.VLC

# Install Keybase.
#
curl -L -O https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
rm -f ./keybase_amd64.deb

# Install ProtonMail Import-Export app
#
curl -L -O https://protonmail.com/download/ie/protonmail-import-export-app_1.3.3-1_amd64.deb
sudo apt install ./protonmail-import-export-app_1.3.3-1_amd64.deb
rm -f ./protonmail-import-export-app_1.3.3-1_amd64.deb

# Install Insync.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.7.6.50356-jammy_amd64.deb
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync-nautilus_3.4.0.40973_all.deb
	sudo apt install ./insync_3.7.6.50356-jammy_amd64.deb
	sudo apt install ./insync-nautilus_3.4.0.40973_all.deb
)
rm -rf "$BUILD_DIR"

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-radicle.sh
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh
source $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh

# Apply application settings, when possible.
#
gsettings set ca.desrt.dconf-editor.Settings          show-warning                   false
gsettings set org.gnome.desktop.interface             clock-format                   "24h"
gsettings set org.gnome.desktop.datetime              automatic-timezone             false
gsettings set org.gnome.desktop.interface             clock-show-weekday             true
gsettings set org.gnome.desktop.interface             document-font-name             "Roboto Slab 13"
gsettings set org.gnome.desktop.interface             font-name                      "Fira Sans Semi-Light 13"
gsettings set org.gnome.desktop.interface             gtk-im-module                  "ibus"
gsettings set org.gnome.desktop.interface             monospace-font-name            "Fira Mono 13"
gsettings set org.gnome.desktop.media-handling        autorun-never                  true
gsettings set org.gnome.desktop.notifications         show-in-lock-screen            true
gsettings set org.gnome.desktop.peripherals.touchpad  natural-scroll                 true
gsettings set org.gnome.desktop.privacy               recent-files-max-age           30
gsettings set org.gnome.desktop.privacy               remove-old-temp-files          true
gsettings set org.gnome.desktop.privacy               remove-old-trash-files         true
gsettings set org.gnome.desktop.privacy               report-technical-problems      false
gsettings set org.gnome.desktop.sound                 allow-volume-above-100-percent true
gsettings set org.gnome.desktop.wm.keybindings        switch-applications            "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings        switch-applications-backward   "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings        switch-windows                 "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings        switch-windows-backward        "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.preferences        button-layout                  "appmenu:minimize,maximize,close"
gsettings set org.gnome.desktop.wm.preferences        titlebar-font                  "Fira Sans Semi-Bold 13"
gsettings set org.gnome.gnome-screenshot              delay                          5
gsettings set org.gnome.gnome-screenshot              last-save-directory            "file://$HOME/Downloads"
gsettings set org.gnome.gnome-system-monitor          solaris-mode                   false
gsettings set org.gnome.gnome-system-monitor.proctree sort-col                       8
gsettings set org.gnome.nautilus.list-view            use-tree-view                  true
gsettings set org.gnome.nautilus.preferences          default-folder-viewer          "list-view"
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled            true
gsettings set org.gnome.shell                         remember-mount-password        true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action                   "cycle-windows"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size             36
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed                     true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position                  "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height                  true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide                    false
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor                  true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts                    true
gsettings set org.gnome.shell.extensions.pop-cosmic   clock-alignment                "RIGHT"
gsettings set org.gnome.shell.extensions.pop-cosmic   workspace-picker-left          false
gsettings set org.gnome.shell.window-switcher         current-workspace-only         false
gsettings set org.gnome.system.location               enabled                        true
gsettings set org.gtk.Settings.FileChooser            clock-format                   "24h"

# Apply settings for relocatable schemas.
#
gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/gnome-power-panel/ enable false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.config/autostart $HOME/.local/bin $HOME/.ssh

cp $CONFIG_PATH/user/bash_aliases                        $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/autostart/solaar.desktop     $HOME/.config/autostart/solaar.desktop
cp $CONFIG_PATH/user/gemrc                               $HOME/.gemrc
cp $CONFIG_PATH/user/inputrc                             $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup.sh                 $HOME/.local/bin/backup.sh
cp $CONFIG_PATH/user/local/bin/update-full.sh            $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-radicle.sh         $HOME/.local/bin/update-radicle.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh          $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh      $HOME/.local/bin/update-youtube-dl.sh
cp $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh $HOME/.local/bin/update-yubikey-manager.sh
cp $CONFIG_PATH/user/ssh/config                          $HOME/.ssh/config

chmod 755 $HOME/.local/bin/*
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*

ln -s $HOME/.local/share/flatpak/exports/share/applications/org.keepassxc.KeePassXC.desktop $HOME/.config/autostart/

mkdir -p $HOME/google/{cardboard-iguana,personal,yak-collective}

# Disable the VirtualBox web service. We don't need it, and it just
# likes to fail and make systemd complain anyway.
#
sudo systemctl disable vboxweb.service

# Add the current user to the vboxusers group. This is necessary to
# enable USB pass-through.
#
sudo usermod -aG vboxusers $USER

# Restore all git repos.
#
mkdir -p $HOME/code
(
	git config --global user.name "Nathan Acks"
	git config --global user.email nathan.acks@cardboard-iguana.com
	git config --global user.signingKey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	git config --global commit.gpgSign true
	cd $HOME/code
	git clone git@github.com:The-Yak-Collective/onboarding_robot.git
	mv onboarding_robot automation-onboarding-robot
	git clone git@github.com:The-Yak-Collective/project_ui.git
	mv project_ui automation-project-ui
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yak-collective
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	mv infrastructure-map doc-infrastructure-map
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@github.com:necopinus/resume.git
	git clone git@github.com:necopinus/zibaldone.git
	mv zibaldone notes-necopinus
	git clone git@github.com:necopinus/cardboard-iguana.com.git
	mv cardboard-iguana.com website-cardboard-iguana.com
	git clone git@github.com:necopinus/chateaumaxmin.info.git
	mv chateaumaxmin.info website-chateaumaxmin.info
	git clone git@github.com:necopinus/ecopunk.info.git
	mv ecopunk.info website-ecopunk.info
	git clone git@github.com:necopinus/ellen-and-nathan.info.git
	mv ellen-and-nathan.info website-ellen-and-nathan.info
	git clone git@github.com:necopinus/delphi-strategy.com.git
	mv delphi-strategy.com website-delphi-strategy.com
	git clone git@github.com:necopinus/digital-orrery.com.git
	mv digital-orrery.com website-digital-orrery.com
	git clone git@github.com:necopinus/necopinus.xyz.git
	mv necopinus.xyz website-necopinus.xyz
	git clone git@github.com:The-Yak-Collective/yakcollective.git
	mv yakcollective website-yakcollective.org
)

# Finish up.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""
sudo reboot
