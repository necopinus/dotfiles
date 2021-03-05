#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../user/"

# Add the NodeSource repository.
#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/nodesource.gpg add -
sudo apt-add-repository https://deb.nodesource.com/node_14.x

# Make sure all components are up-to-date.
#
sudo apt install apt-transport-https
sudo apt update
sudo apt full-upgrade
sudo apt autoremove --purge --autoremove
sudo apt clean

flatpak update
flatpak uninstall --unused

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
bundler \
code \
dconf-editor \
dino-im \
discord \
dos2unix \
fonts-cascadia-code \
fonts-croscore \
fonts-crosextra-caladea \
fonts-crosextra-carlito \
fonts-noto \
fonts-roboto \
graphicsmagick \
graphviz \
ibus-typing-booster \
jhead \
nodejs \
optipng \
p7zip-full \
qalc \
virtualbox-ext-pack \
virtualbox-guest-additions-iso

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

# No firewall is enabled by default, because apparently we still live in
# 1995.
#
sudo ufw enable

# Restore scripts and configurations from this repo.
#
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
cp $CONFIG_PATH/local/share/applications/ykman.desktop $HOME/.local/share/applications/ykman.desktop

chmod 755 $HOME/.local/bin/backup-cloud.sh

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
