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
bloodhound \
dconf-editor \
fonts-noto \
gobuster \
golang \
htop \
jython \
libreadline-dev \
libssl-dev \
maven \
openjdk-11-jdk \
python3-capstone \
python3-pip \
qalc \
rlwrap \
seclists

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-kerbrute.sh
source $CONFIG_PATH/user/local/bin/update-volatility.sh
source $CONFIG_PATH/user/local/bin/update-xsrfprobe.sh

# Setup Evil-WinRM.
#
gem install --user-install evil-winrm

# Refresh files from /etc/skel.
#
mkdir -p $HOME/.config/powershell
mkdir -p $HOME/.config/xfce4/panel
mkdir -p $HOME/.java/.userPrefs/burp

sudo cp /etc/skel/.bash_logout                                        $HOME/.bash_logout
sudo cp /etc/skel/.bashrc                                             $HOME/.bashrc
sudo cp /etc/skel/.face                                               $HOME/.face
sudo cp /etc/skel/.profile                                            $HOME/.profile
sudo cp /etc/skel/.zshrc                                              $HOME/.zshrc
sudo cp /etc/skel/.java/.userPrefs/burp/prefs.xml                     $HOME/.java/.userPrefs/burp/prefs.xml
sudo cp /etc/skel/.config/powershell/Microsoft.PowerShell_profile.ps1 $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1
sudo cp /etc/skel/.config/xfce4/panel/cpugraph-13.rc                  $HOME/.config/xfce4/panel/cpugraph-13.rc
sudo cp /etc/skel/.config/xfce4/panel/genmon-15.rc                    $HOME/.config/xfce4/panel/genmon-15.rc

sudo chown $USER.$USER $HOME/.bash_logout
sudo chown $USER.$USER $HOME/.bashrc
sudo chown $USER.$USER $HOME/.face
sudo chown $USER.$USER $HOME/.profile
sudo chown $USER.$USER $HOME/.zshrc
sudo chown $USER.$USER $HOME/.java/.userPrefs/burp/prefs.xml
sudo chown $USER.$USER $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1
sudo chown $USER.$USER $HOME/.config/xfce4/panel/cpugraph-13.rc
sudo chown $USER.$USER $HOME/.config/xfce4/panel/genmon-15.rc

chmod 644 $HOME/.bash_logout
chmod 644 $HOME/.bashrc
chmod 644 $HOME/.face
chmod 644 $HOME/.profile
chmod 644 $HOME/.zshrc
chmod 644 $HOME/.java/.userPrefs/burp/prefs.xml
chmod 644 $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1
chmod 644 $HOME/.config/xfce4/panel/cpugraph-13.rc
chmod 644 $HOME/.config/xfce4/panel/genmon-15.rc

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
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac      -t int    -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -t int    -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled     -t bool   -s false
xfconf-query -n -c xfce4-session       -p /general/AutoSave                     -t bool   -s false
xfconf-query -n -c xfce4-session       -p /general/PromptOnLogout               -t bool   -s false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share

cp    $CONFIG_PATH/user/bash_aliases                   $HOME/.bash_aliases
cp    $CONFIG_PATH/user/gemrc                          $HOME/.gemrc
cp    $CONFIG_PATH/user/inputrc                        $HOME/.inputrc
cp    $CONFIG_PATH/user/local/bin/update-full.sh       $HOME/.local/bin/update-full.sh
cp    $CONFIG_PATH/user/local/bin/update-kerbrute.sh   $HOME/.local/bin/update-kerbrute.sh
cp    $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp    $CONFIG_PATH/user/local/bin/update-volatility.sh $HOME/.local/bin/update-volatility.sh
cp    $CONFIG_PATH/user/local/bin/update-xsrfprobe.sh  $HOME/.local/bin/update-xsrfprobe.sh
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
