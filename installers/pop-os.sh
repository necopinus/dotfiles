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

# Allow port 3131 TCP + WebRTC ports for Deskreen.
#
sudo ufw allow from 0.0.0.0/0 port  3131       proto tcp
sudo ufw allow from 0.0.0.0/0 port 49800:49899 proto tcp

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

# Add Google repos. See:
#
#     https://support.google.com/a/users/answer/9018161#linuxhelper
#
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/local/share/keyrings/cloud.google.gpg add -
echo "deb [signed-by=/usr/local/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
echo "deb [signed-by=/usr/local/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt endpoint-verification main" | sudo tee /etc/apt/sources.list.d/endpoint-verification.list

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
default-jre \
endpoint-verification \
exfatprogs \
fonts-noto \
google-chrome-stable \
google-cloud-sdk \
graphicsmagick \
graphviz \
grub-pc \
htop \
jq \
libjpeg-turbo-progs \
network-manager-openvpn-gnome \
npm \
optipng \
python3-bs4 \
python3-pip \
qalc \
vim \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
winetricks \
xdotool \
youtube-dl

flatpak install --user flathub ca.desrt.dconf-editor
flatpak install --user flathub com.discordapp.Discord
flatpak install --user flathub com.system76.Popsicle
flatpak install --user flathub com.visualstudio.code
flatpak install --user flathub fr.handbrake.ghb
flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.gnome.baobab
flatpak install --user flathub org.gnome.eog
flatpak install --user flathub org.gnome.Evince
flatpak install --user flathub org.gnome.FileRoller
flatpak install --user flathub org.gnome.PowerStats
flatpak install --user flathub org.gnome.seahorse.Application
flatpak install --user flathub org.gnome.SoundJuicer
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.soundconverter.SoundConverter
flatpak install --user flathub org.videolan.VLC
flatpak install --user flathub us.zoom.Zoom

# Install Keybase.
#
curl -L -O https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
rm -f ./keybase_amd64.deb

# Install Insync.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.5.4.50130-focal_amd64.deb
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync-nautilus_3.4.0.40973_all.deb
	sudo apt install ./insync_3.5.4.50130-focal_amd64.deb
	sudo apt install ./insync-nautilus_3.4.0.40973_all.deb
)
rm -rf "$BUILD_DIR"

# Install SonicWall NetExtender
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	NETEXTENDER_INSTALLER="NetExtender.Linux-10.2.828.x86_64.tgz"
	curl -L -O https://software.sonicwall.com/NetExtender/$NETEXTENDER_INSTALLER
	tar -xzf $NETEXTENDER_INSTALLER
	cd netExtenderClient
	sudo ./install
)
rm -rf "$BUILD_DIR"

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-deskreen.sh
source $CONFIG_PATH/user/local/bin/update-gam.sh
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh
source $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh

# Download and install additional application icons.
#
mkdir -p $HOME/.local/share/icons
(
	cd $HOME/.local/share/icons
	curl -L -O https://raw.githubusercontent.com/Yubico/yubikey-manager-qt/master/resources/icons/ykman.png
	curl -L -O https://raw.githubusercontent.com/pavlobu/deskreen/master/resources/icon.png
	mv icon.png deskreen.png
)

# Apply application settings, when possible.
#
gsettings set ca.desrt.dconf-editor.Settings             show-warning                   false
gsettings set org.gnome.desktop.interface                clock-format                   "24h"
gsettings set org.gnome.desktop.interface                clock-show-weekday             true
gsettings set org.gnome.desktop.interface                document-font-name             "Roboto Slab 13"
gsettings set org.gnome.desktop.interface                font-name                      "Fira Sans Semi-Light 13"
gsettings set org.gnome.desktop.interface                gtk-im-module                  "ibus"
gsettings set org.gnome.desktop.interface                monospace-font-name            "Fira Mono 13"
gsettings set org.gnome.desktop.media-handling           autorun-never                  true
gsettings set org.gnome.desktop.notifications            show-in-lock-screen            true
gsettings set org.gnome.desktop.peripherals.touchpad     natural-scroll                 true
gsettings set org.gnome.desktop.privacy                  recent-files-max-age           30
gsettings set org.gnome.desktop.privacy                  remove-old-temp-files          true
gsettings set org.gnome.desktop.privacy                  remove-old-trash-files         true
gsettings set org.gnome.desktop.privacy                  report-technical-problems      false
gsettings set org.gnome.desktop.sound                    allow-volume-above-100-percent true
gsettings set org.gnome.desktop.wm.keybindings           switch-applications            "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-applications-backward   "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows                 "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings           switch-windows-backward        "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.preferences           button-layout                  "appmenu:minimize,maximize,close"
gsettings set org.gnome.desktop.wm.preferences           titlebar-font                  "Fira Sans Semi-Bold 13"
gsettings set org.gnome.gnome-screenshot                 delay                          5
gsettings set org.gnome.gnome-screenshot                 last-save-directory            "file://$HOME/Downloads"
gsettings set org.gnome.gnome-system-monitor             solaris-mode                   false
gsettings set org.gnome.gnome-system-monitor.proctree    sort-col                       8
gsettings set org.gnome.nautilus.list-view               use-tree-view                  true
gsettings set org.gnome.nautilus.preferences             default-folder-viewer          "list-view"
gsettings set org.gnome.settings-daemon.plugins.color    night-light-enabled            true
gsettings set org.gnome.shell                            remember-mount-password        true
gsettings set org.gnome.shell.extensions.dash-to-dock    dash-max-icon-size             60
gsettings set org.gnome.shell.extensions.dash-to-dock    dock-fixed                     false
gsettings set org.gnome.shell.extensions.dash-to-dock    extend-height                  false
gsettings set org.gnome.shell.extensions.dash-to-dock    intellihide                    true
gsettings set org.gnome.shell.extensions.dash-to-dock    multi-monitor                  true
gsettings set org.gnome.shell.extensions.dash-to-dock    show-mounts                    false
gsettings set org.gnome.shell.extensions.pop-cosmic      clock-alignment                "RIGHT"
gsettings set org.gnome.shell.weather                    automatic-location             true
gsettings set org.gnome.shell.window-switcher            current-workspace-only         false
gsettings set org.gnome.system.location                  enabled                        true
gsettings set org.gtk.Settings.FileChooser               clock-format                   "24h"

flatpak run --command=gsettings org.gnome.SoundJuicer             set org.gnome.sound-juicer audio-profile    "audio/mpeg"
flatpak run --command=gsettings org.gnome.SoundJuicer             set org.gnome.sound-juicer file-pattern     "%at - %dn - %ta - %tt"
flatpak run --command=gsettings org.gnome.SoundJuicer             set org.gnome.sound-juicer path-pattern     "%at"
flatpak run --command=gsettings org.soundconverter.SoundConverter set org.soundconverter     mp3-vbr-quality  0
flatpak run --command=gsettings org.soundconverter.SoundConverter set org.soundconverter     output-mime-type "audio/mpeg"

# Apply settings for relocatable schemas.
#
gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/gnome-power-panel/ enable false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications

cp $CONFIG_PATH/user/bash_aliases                                          $HOME/.bash_aliases
cp $CONFIG_PATH/user/gitconfig                                             $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                                               $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup.sh                                   $HOME/.local/bin/backup.sh
cp $CONFIG_PATH/user/local/bin/update-full.sh                              $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-deskreen.sh                          $HOME/.local/bin/update-deskreen.sh
cp $CONFIG_PATH/user/local/bin/update-gam.sh                               $HOME/.local/bin/update-gam.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh                            $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh                        $HOME/.local/bin/update-youtube-dl.sh
cp $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh                   $HOME/.local/bin/update-yubikey-manager.sh
cp $CONFIG_PATH/user/local/share/applications/ykman.desktop                $HOME/.local/share/applications/ykman.desktop

chmod 755 $HOME/.local/bin/*

mkdir -p $HOME/Google/{"Cardboard Iguana",Personal,"Yak Collective"}

# Disable the VirtualBox web service. We don't need it, and it just
# likes to fail and make systemd complain anyway.
#
sudo systemctl disable vboxweb.service

# Restore all git repos.
#
mkdir -p $HOME/Code
(
	git config --global user.email nathan.acks@cardboard-iguana.com
	git config --global user.signingkey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	cd $HOME/Code
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
	git clone git@bitbucket.org:necopinus/hugo-theme-story.git
	git clone git@bitbucket.org:necopinus/website-chateaumaxmin.info.git
	git clone git@bitbucket.org:necopinus/website-delphi-strategy.com.git
	git clone git@bitbucket.org:necopinus/website-digital-orrery.com.git
	git clone git@bitbucket.org:necopinus/website-ecopunk.info.git
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
