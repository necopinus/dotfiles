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

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Cleanup unneeded software.
#
sudo apt purge --autoremove --purge \
geary \
gedit \
gnome-calculator \
gnome-calendar \
gnome-contacts \
gnome-font-viewer \
gnome-weather \
gucharmap \
libreoffice-common \
simple-scan \
totem

# Clean up random files/directories.
#
sudo rm -rf /usr/share/fonts/truetype/libreoffice

# Install new applications.
#
sudo apt install \
bundler \
code \
dconf-editor \
discord \
dos2unix \
exfatprogs \
fonts-noto \
graphicsmagick \
graphviz \
grub-pc \
handbrake \
htop \
ibus-typing-booster \
jhead \
jq \
libpcsclite-dev \
optipng \
p7zip-full \
python3-bs4 \
qalc \
sound-juicer \
soundconverter \
swig \
vim \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
virtualenv \
xdotool \
youtube-dl

flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.keepassxc.KeePassXC
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.videolan.VLC

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

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-youtube-dl.sh
source $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings             show-warning                   false
gsettings set org.freedesktop.ibus.engine.typing-booster dictionary                     "en_US"
gsettings set org.freedesktop.ibus.engine.typing-booster emojipredictions               true
gsettings set org.freedesktop.ibus.engine.typing-booster inputmethod                    "NoIME"
gsettings set org.gnome.desktop.input-sources            mru-sources                    "[('xkb','us'),('ibus','typing-booster')]"
gsettings set org.gnome.desktop.input-sources            sources                        "[('xkb','us'),('ibus','typing-booster')]"
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
gsettings set org.gnome.sound-juicer                     audio-profile                  "audio/mpeg"
gsettings set org.gnome.sound-juicer                     file-pattern                   "%at - %dn - %ta - %tt"
gsettings set org.gnome.sound-juicer                     path-pattern                   "%at"
gsettings set org.gnome.system.location                  enabled                        true
gsettings set org.gtk.Settings.FileChooser               clock-format                   "24h"
gsettings set org.soundconverter                         mp3-vbr-quality                0
gsettings set org.soundconverter                         output-mime-type               "audio/mpeg"

# Apply settings for relocatable schemas.
#
gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/gnome-power-panel/ enable false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.config/gtk-3.0
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                        $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/gtk-3.0/bookmarks-pop-os     $HOME/.config/gtk-3.0/bookmarks
cp $CONFIG_PATH/user/config/user-dirs.dirs               $HOME/.config/user-dirs.dirs
cp $CONFIG_PATH/user/gitconfig                           $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                             $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup-local.sh           $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/user/local/bin/update-full.sh            $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh          $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-youtube-dl.sh      $HOME/.local/bin/update-youtube-dl.sh
cp $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh $HOME/.local/bin/update-yubikey-manager.sh

chmod 755 $HOME/.local/bin/*

mkdir -p $HOME/Google $HOME/"Yak Collective"
rm -rf $HOME/Music $HOME/Pictures $HOME/Templats $HOME/Videos

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
