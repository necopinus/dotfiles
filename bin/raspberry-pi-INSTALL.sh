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
sudo ufw allow in on eth0 from 10.54.0.0/29 to 10.54.0.1 port 1313 proto tcp
sudo ufw allow in on eth0 from 10.54.0.0/29 to 10.54.0.1 port 4000 proto tcp

sudo ufw allow in on usb0 from 10.55.0.0/29 to 10.55.0.1 port 1313 proto tcp
sudo ufw allow in on usb0 from 10.55.0.0/29 to 10.55.0.1 port 4000 proto tcp

# Disable the Raspberry Pi's default overscan, as this doesn't play nice
# with any of my monitors.
#
sudo sed -i -e 's/^#disable_overscan=1$/disable_overscan=1/' /boot/config.txt

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
asciinema \
burpsuite \
code-oss \
dconf-editor \
exfat-utils \
flatpak \
fonts-noto \
gobuster \
golang \
graphicsmagick \
handbrake \
htop \
jhead \
jq \
optipng \
qalc \
qtqr \
rlwrap \
seclists \
sound-juicer \
soundconverter \
youtube-dl \
yubikey-manager \
yubikey-personalization-gui

# The above packages supercede some installed packages, so we do some
# additional cleanup here.
#
sudo apt autoremove --purge --autoremove

# Install (beta) ARM64 build of Insync. See:
#
#     https://forums.insynchq.com/t/arm64-headless-test-build/17680
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/test_builds/insync-headless_3.1.6.10648-stretch_arm64.deb
	sudo apt install ./insync-headless_3.1.6.10648-stretch_arm64.deb
)
rm -rf "$BUILD_DIR"

# Setup Flatpak and install Obsidian.
#
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub md.obsidian.Obsidian

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-keybase.sh

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

xfconf-query -c displays      -p /AutoEnableProfiles         -t bool   -s true
xfconf-query -c displays      -p /Notify                     -t bool   -s true
xfconf-query -c xfce4-panel   -p /plugins/plugin-15/timezone -t string -s "US/Mountain"
xfconf-query -c xfce4-session -p /general/AutoSave           -t bool   -s false
xfconf-query -c xfce4-session -p /general/PromptOnLogout     -t bool   -s false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.config/gtk-3.0
mkdir -p $HOME/.config/systemd/user/default.target.wants
mkdir -p $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                                $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/gtk-3.0/bookmarks-kali               $HOME/.config/gtk-3.0/bookmarks
cp $CONFIG_PATH/user/config/systemd/user/insync-headless.service $HOME/.config/systemd/user/insync-headless.service
cp $CONFIG_PATH/user/config/user-dirs.dirs                       $HOME/.config/user-dirs.dirs
cp $CONFIG_PATH/user/gitconfig                                   $HOME/.gitconfig
cp $CONFIG_PATH/user/inputrc                                     $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup-local.sh                   $HOME/.local/bin/backup-local.sh
cp $CONFIG_PATH/user/local/bin/update-full.sh                    $HOME/.local/bin/update-full.sh
cp $CONFIG_PATH/user/local/bin/update-keybase.sh                 $HOME/.local/bin/update-keybase.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh                  $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/tmux.conf                                   $HOME/.tmux.conf

chmod 755 $HOME/.local/bin/*

ln -s $HOME/.config/systemd/user/insync-headless.service $HOME/.config/systemd/user/default.target.wants/insync-headless.service

rm -rf $HOME/Music $HOME/Pictures $HOME/Templats $HOME/Videos

# Set up Metasploit.
#
sudo systemctl enable postgresql.service
sudo msfdb init

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

# Finish up part 1.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""

sudo reboot
