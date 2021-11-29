#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Make sure that my user has access to all VirtualBox mounts, etc.
#
sudo adduser $USER vboxsf

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
asciinema \
beef-xss \
dconf-editor \
fonts-noto \
gobuster \
golang \
htop \
python3-capstone \
python3-pip \
qalc \
rlwrap \
seclists

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-volatility.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings show-warning false
gsettings set org.gtk.Settings.FileChooser   clock-format "24h"

xfconf-query -n -c displays            -p /AutoEnableProfiles                   -t bool   -s true
xfconf-query -n -c displays            -p /Notify                               -t bool   -s true
xfconf-query -n -c xfce4-panel         -p /plugins/plugin-15/timezone           -t string -s "US/Mountain"
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac      -t int   -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -t int   -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled     -t bool   -s false
xfconf-query -n -c xfce4-session       -p /general/AutoSave                     -t bool   -s false
xfconf-query -n -c xfce4-session       -p /general/PromptOnLogout               -t bool   -s false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share

cp    $CONFIG_PATH/user/bash_aliases                   $HOME/.bash_aliases
cp    $CONFIG_PATH/user/inputrc                        $HOME/.inputrc
cp    $CONFIG_PATH/user/local/bin/update-full.sh       $HOME/.local/bin/update-full.sh
cp    $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp    $CONFIG_PATH/user/local/bin/update-volatility.sh $HOME/.local/bin/update-volatility.sh
cp -r $CONFIG_PATH/user/local/share/red-team           $HOME/.local/share/red-team
cp    $CONFIG_PATH/user/zshenv                         $HOME/.zshenv

chmod 755 $HOME/.local/bin/*

# Uncompress rockyou.txt.
#
if [[ -f /usr/share/wordlists/rockyou.txt.gz ]]; then
	mkdir -p $HOME/.local/share/red-team/wordlists
	cp /usr/share/wordlists/rockyou.txt.gz $HOME/.local/share/red-team/wordlists/
	gunzip $HOME/.local/share/red-team/wordlists/rockyou.txt.gz
fi

# Set up Metasploit.
#
sudo systemctl enable postgresql.service
sudo msfdb init

# Finish up part 1.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""

sudo reboot
