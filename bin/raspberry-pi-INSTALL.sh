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
fonts-noto \
gobuster \
golang \
graphicsmagick \
htop \
python3-capstone \
qalc \
rlwrap \
seclists \
youtube-dl \
yubikey-manager \
yubikey-personalization-gui

# The above packages supercede some installed packages, so we do some
# additional cleanup here.
#
sudo apt autoremove --purge --autoremove

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-keybase.sh
source $CONFIG_PATH/user/local/bin/update-volatility.sh

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set ca.desrt.dconf-editor.Settings show-warning false
gsettings set org.gtk.Settings.FileChooser   clock-format "24h"

xfconf-query -c displays      -p /AutoEnableProfiles         -t bool   -s true
xfconf-query -c displays      -p /Notify                     -t bool   -s true
xfconf-query -c xfce4-panel   -p /plugins/plugin-15/timezone -t string -s "US/Mountain"
xfconf-query -c xfce4-session -p /general/AutoSave           -t bool   -s false
xfconf-query -c xfce4-session -p /general/PromptOnLogout     -t bool   -s false

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share

cp    $CONFIG_PATH/user/bash_aliases                   $HOME/.bash_aliases
cp    $CONFIG_PATH/user/gitconfig                      $HOME/.gitconfig
cp    $CONFIG_PATH/user/inputrc                        $HOME/.inputrc
cp    $CONFIG_PATH/user/local/bin/backup-local.sh      $HOME/.local/bin/backup-local.sh
cp    $CONFIG_PATH/user/local/bin/update-full.sh       $HOME/.local/bin/update-full.sh
cp    $CONFIG_PATH/user/local/bin/update-keybase.sh    $HOME/.local/bin/update-keybase.sh
cp    $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp    $CONFIG_PATH/user/local/bin/update-volatility.sh $HOME/.local/bin/update-volatility.sh
cp -r $CONFIG_PATH/user/local/share/red-team           $HOME/.local/share/red-team
cp    $CONFIG_PATH/user/tmux.conf                      $HOME/.tmux.conf

chmod 755 $HOME/.local/bin/*

mkdir -p $HOME/Google/{"Cardboard Iguana",Personal,"Yak Collective"}

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
