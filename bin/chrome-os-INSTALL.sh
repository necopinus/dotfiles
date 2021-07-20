#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Add the NodeSource repository. See:
#
#     https://node.dev/node-binary
#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/nodesource.gpg add -
sudo apt-add-repository https://deb.nodesource.com/node_14.x

# Add the Yubico PPA, again because Ubuntu's repos are out-of-date.
#
sudo apt-add-repository ppa:yubico/stable

# Make sure all components are up-to-date.
#
sudo apt install apt-transport-https
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
golang \
google-chrome-stable \
graphicsmagick \
graphviz \
grub-pc \
handbrake \
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
virtualenv \
xdotool \
youtube-dl \
yubikey-manager

flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.gimp.GIMP
flatpak install --user flathub org.keepassxc.KeePassXC
flatpak install --user flathub org.openshot.OpenShot
flatpak install --user flathub org.signal.Signal
flatpak install --user flathub org.videolan.VLC

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
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases               $HOME/.bash_aliases
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
	clone git@bitbucket.org:tpin-it-security/assets-okta.git
	git clone git@bitbucket.org:tpin-it-security/automation-it-lifecycle.git
	git clone git@bitbucket.org:tpin-it-security/computer-setup.git
	mv computer-setup automation-computer-setup
)
