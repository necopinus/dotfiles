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

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Remove colord, as it generates annoying prompts when running XFCE over
# RDP.
#
sudo apt purge --autoremove --purge colord

# Install new applications.
#
sudo apt install \
armitage \
build-essential \
burpsuite \
chromium \
cupp \
gobuster \
gufw \
ipcalc \
jq \
linux-exploit-suggester \
mingw-w64 \
npm \
peass \
powercat \
python3-pip \
qalc \
seclists \
youtube-dl

# The above packages supercede some installed packages, so we do some
# additional cleanup here.
#
sudo apt autoremove --purge --autoremove

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-ligolo.sh
source $CONFIG_PATH/user/local/bin/update-ngrok.sh

# Some Burp Suite extensions need Jython.
#
mkdir "Burp Suite"
(
	cd $HOME/"Burp Suite"
	curl -L -O https://repo1.maven.org/maven2/org/python/jython-standalone/2.7.2/jython-standalone-2.7.2.jar
)

# 1991 called. They want their disabled-by-default firewall back.
#
sudo ufw enable
sudo ufw default deny

# Make sure that Bluetooth is disabled on startup.
#
sudo sed -i -e 's/^AutoEnable=true$/#AutoEnable=true/' /etc/bluetooth/main.conf

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

cp $CONFIG_PATH/user/bash_aliases               $HOME/.bash_aliases
cp $CONFIG_PATH/user/inputrc                    $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-ligolo.sh $HOME/.local/bin/update-ligolo.sh
cp $CONFIG_PATH/user/local/bin/update-ngrok.sh  $HOME/.local/bin/update-ngrok.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/tmux.conf                  $HOME/.tmux.conf
cp $CONFIG_PATH/user/zinit                      $HOME/.zinit
cp $CONFIG_PATH/user/zprofile                   $HOME/.zprofile
cp $CONFIG_PATH/user/zshenv                     $HOME/.zshenv

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
sudo make-ssl-cert generate-default-snakeoil
sudo systemctl enable postgresql.service
sudo msfdb init

# The following rule is needed to access Armitage "remotely" over usb0.
#
if [[ -f /boot/config.txt ]]; then
	ufw allow in on usb0 from 10.55.0.0/29 to 10.55.0.1 port 55553 proto tcp
#else
#	ufw allow in on eth0 from 0.0.0.0/0 to 0.0.0.0/0 port 55553 proto tcp
fi

# Restore select git repos.
#
mkdir $HOME/Repos
(
	cd $HOME/Repos
	git clone https://github.com/necopinus/dotfiles.git
	git clone https://github.com/EmpireProject/Empire.git
	git clone https://github.com/GTFOBins/GTFOBins.github.io.git
	git clone https://github.com/cardboard-iguana/hacking-notes.git
	git clone https://github.com/carlospolop/hacktricks.git
	git clone https://github.com/carlospolop/hacktricks-cloud.git
	git clone https://github.com/lmammino/jwt-cracker.git
	git clone https://github.com/rebootuser/LinEnum.git
	git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
	git clone https://github.com/GhostPack/Rubeus.git
	git clone https://github.com/Mr-Un1k0d3r/SCShell.git
	git clone https://github.com/nikitastupin/solc.git
	chmod +x solc/linux/aarch64/solc-*
	ln -s $HOME/Repos/solc/linux/aarch64 $HOME/.solcx
	git clone https://github.com/therodri2/username_generator.git
)

# Finis.
#
echo "A reboot is required for some features to become available."
