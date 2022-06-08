#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Make sure that we're using /usr/bin/zsh for our shell (for whatever
# reason, the Raspberry Pi images use /bin/bash instead).
#
chsh --shell /usr/bin/zsh

# Make sure that locale is properly set. Probably only necessary for the
# Raspberry Pi images.
#
sudo dpkg-reconfigure locales

# Make sure that the timezone is properly set. Probably only necessary
# for the Raspberry Pi images.
#
sudo dpkg-reconfigure tzdata

# Disable the Raspberry Pi's default overscan, as this doesn't play nice
# with any of my monitors.
#
if [[ -f /boot/config.txt ]]; then
	sudo sed -i -e 's/^#disable_overscan=1$/disable_overscan=1/' /boot/config.txt
fi

# Make sure that my user has access to all VirtualBox mounts, etc.
#
if [[ $(grep -Ec "^vboxsf:" /etc/group) -eq 1 ]]; then
	sudo adduser $USER vboxsf
fi

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Remove /usr/bin/python2 -> /usr/bin/python symlink (and eliminate
# associated login warning). See:
#
#     https://www.kali.org/docs/general-use/python3-transition/
#
sudo apt remove --purge --autoremove python-is-python2

# Remove colord, as it generates annoying prompts when running XFCE over
# XRDP on the Raspberry Pi and isn't necesary on a VM.
#
sudo apt purge --autoremove --purge colord

# Install new applications.
#
sudo apt install \
build-essential \
burpsuite \
chromium \
exfatprogs \
fonts-noto \
gcc-mingw-w64-x86-64 \
ghidra \
gobuster \
golang \
graphicsmagick \
gufw \
htop \
jq \
libreadline-dev \
libssl-dev \
linux-exploit-suggester \
maven \
npm \
openjdk-11-jdk \
python3-capstone \
python3-pip \
qalc \
ripgrep \
ruby-httpclient \
seclists \
testssl.sh \
webp

# The above packages supercede some installed packages, so we do some
# additional cleanup here.
#
sudo apt autoremove --purge --autoremove

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-kerbrute.sh
source $CONFIG_PATH/user/local/bin/update-kiterunner.sh
source $CONFIG_PATH/user/local/bin/update-ngrok.sh

# 1991 called. They want their disabled-by-default firewall back.
#
sudo ufw enable
sudo ufw default deny

# Make sure wireless connections do NOT auto-connect!
#
cat > /tmp/nm-autoconnect-false << EOF
#!/usr/bin/bash                                                                                                                                       
                                                                                                                                                      
while IFS= read -d '' -r NMCONNECTION; do                                                                                                             
	UUID="$(grep uuid "$NMCONNECTION" | sed -e 's/.*=//')"
	TYPE="$(nmcli --fields connection.type connection show "$UUID" | sed -e 's/.*\s//')"
	if [[ "$TYPE" == "802-11-wireless" ]]; then
		AUTOCONNECT="$(nmcli --fields connection.autoconnect connection show "$UUID" | sed -e 's/.*\s//')"
		if [[ "$AUTOCONNECT" == "yes" ]]; then
			nmcli connection modify "$UUID" connection.autoconnect no
		fi
	fi
done < <(find /etc/NetworkManager/system-connections -type f -iname '*.nmconnection' -print0)
EOF
sudo mv /tmp/nm-autoconnect-false /etc/cron.hourly/nm-autoconnect-false
sudo chown root.root /etc/cron.hourly/nm-autoconnect-false
sudo chmod 755 /etc/cron.hourly/nm-autoconnect-false

# Apply application settings, when possible.
#
# To access/manipulate gsettings in a flatpak, use:
#
#   flatpak run --command=gsettings $APP_REF $GSETTINGS_COMMAND_LINE
#
gsettings set org.gtk.Settings.FileChooser clock-format "24h"

xfconf-query -n -c displays            -p /AutoEnableProfiles                   -t bool   -s true
xfconf-query -n -c displays            -p /Notify                               -t bool   -s true
xfconf-query -n -c xfce4-panel         -p /plugins/plugin-15/timezone           -t string -s "US/Mountain"
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac      -t int    -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -t int    -s 0
xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled     -t bool   -s false

# Local SSH config.
#
mkdir -p $HOME/.ssh
cat > $HOME/.ssh/config << EOF
# Defaults
#
Host *
	ForwardAgent no
EOF
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.local/bin

cp    $CONFIG_PATH/user/bash_aliases                   $HOME/.bash_aliases
cp    $CONFIG_PATH/user/inputrc                        $HOME/.inputrc
cp    $CONFIG_PATH/user/local/bin/backup.sh            $HOME/.local/bin/backup.sh
cp    $CONFIG_PATH/user/local/bin/update.sh            $HOME/.local/bin/update.sh
cp    $CONFIG_PATH/user/local/bin/update-kerbrute.sh   $HOME/.local/bin/update-kerbrute.sh
cp    $CONFIG_PATH/user/local/bin/update-kiterunner.sh $HOME/.local/bin/update-kiterunner.sh
cp    $CONFIG_PATH/user/local/bin/update-ngrok.sh      $HOME/.local/bin/update-ngrok.sh
cp    $CONFIG_PATH/user/local/bin/update-system.sh     $HOME/.local/bin/update-system.sh
cp    $CONFIG_PATH/user/local/bin/update-volatility.sh $HOME/.local/bin/update-volatility.sh
cp    $CONFIG_PATH/user/local/bin/update-xsrfprobe.sh  $HOME/.local/bin/update-xsrfprobe.sh
cp -r $CONFIG_PATH/user/local/share/red-team           $HOME/.local/share/red-team
cp    $CONFIG_PATH/user/tmux.conf                      $HOME/.tmux.conf
cp    $CONFIG_PATH/user/zpath                          $HOME/.zpath
cp    $CONFIG_PATH/user/zprofile                       $HOME/.zprofile
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

# Restore select git repos.
#
mkdir $HOME/Repos
(
	cd $HOME/Repos
	git clone https://github.com/necopinus/dotfiles.git
)

# Finis.
#
echo "A reboot is required for some features to become available."
echo ""
read -p "When ready, press any key to reboot... " -n1 -s
echo ""

sudo reboot
