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

# Add Brave repo. See:
#
#     https://brave.com/linux/
#
curl -L -O https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo mv brave-browser-archive-keyring.gpg /usr/local/share/keyrings/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/local/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Add Proton VPN repo. See:
#
#     https://protonvpn.com/support/linux-ubuntu-vpn-setup/
#
curl -L -O https://protonvpn.com/download/protonvpn-stable-release_1.0.1-1_all.deb
sudo apt install ./protonvpn-stable-release_1.0.1-1_all.deb
rm -f ./protonvpn-stable-release_1.0.1-1_all.deb

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications.
#
sudo apt install \
aircrack-ng \
apktool \
arp-scan
asciinema \
brave-browser \
bundler \
cmake \
code \
discord \
dsniff \
exfatprogs \
expect \
ffuf \
fonts-noto \
gimp \
gir1.2-appindicator3-0.1 \
gnome-screenshot \
gobuster \
golang \
graphicsmagick \
graphviz \
grub-pc \
handbrake \
hashcat \
hping3 \
hydra \
ike-scan \
ipcalc \
john \
jq \
keepassxc \
libdvd-pkg \
libjpeg-turbo-progs \
libreadline-dev \
libsqlite3-dev \
nbtscan \
nikto \
nmap \
npm \
optipng \
protonvpn \
python3-bs4 \
python3-openssl \
python3-pip \
qalc \
qtqr \
rdesktop \
ripgrep \
rlwrap \
rust-all \
samdump2 \
sipcrack \
sipsak \
slack-desktop \
slowhttptest \
socat \
solaar \
sound-juicer \
sqlmap \
testssl.sh \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
virtualenv \
webp \
wireshark \
youtube-dl

flatpak install --user flathub com.getpostman.Postman
flatpak install --user flathub fi.skyjake.Lagrange
flatpak install --user flathub md.obsidian.Obsidian
flatpak install --user flathub org.ghidra_sre.Ghidra
flatpak install --user flathub org.signal.Signal

# Install Keybase.
#
curl -L -O https://prerelease.keybase.io/keybase_amd64.deb
sudo apt install ./keybase_amd64.deb
rm -f ./keybase_amd64.deb

# Install ProtonMail Import-Export app
#
curl -L -O https://protonmail.com/download/ie/protonmail-import-export-app_1.3.3-1_amd64.deb
sudo apt install ./protonmail-import-export-app_1.3.3-1_amd64.deb
rm -f ./protonmail-import-export-app_1.3.3-1_amd64.deb

# Install Insync.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.7.6.50356-jammy_amd64.deb
	curl -L -O https://d2t3ff60b2tol4.cloudfront.net/builds/insync-nautilus_3.4.0.40973_all.deb
	sudo apt install ./insync_3.7.6.50356-jammy_amd64.deb
	sudo apt install ./insync-nautilus_3.4.0.40973_all.deb
)
rm -rf "$BUILD_DIR"

mkdir -p $HOME/Google

# Additional "loose" installs. These are all handled through update
# scripts (which fortunately can also handle the initial installation.
#
source $CONFIG_PATH/user/local/bin/update-radicle.sh
source $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh

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
ssh-keygen -C "nathan.acks@cardboard-iguana.com $(date "+%Y-%m-%d")" -t ed25519
cat > $HOME/.ssh/config << EOF
# Defaults
#
Host *
	Compression  yes
	ForwardAgent no
	IdentityFile ~/.ssh/id_ed25519
EOF
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*
echo ""
echo "Add this SSH key to GitHub and the Raspberry Pi before continuing!"
read -p "Press any key to continue... " -n1 -s

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.config/autostart $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases                        $HOME/.bash_aliases
cp $CONFIG_PATH/user/config/autostart/solaar.desktop     $HOME/.config/autostart/solaar.desktop
cp $CONFIG_PATH/user/inputrc                             $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup.sh                 $HOME/.local/bin/backup.sh
cp $CONFIG_PATH/user/local/bin/update.sh                 $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-radicle.sh         $HOME/.local/bin/update-radicle.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh          $HOME/.local/bin/update-system.sh
cp $CONFIG_PATH/user/local/bin/update-yubikey-manager.sh $HOME/.local/bin/update-yubikey-manager.sh

chmod 755 $HOME/.local/bin/*

# Make sure that KeePassXC auto starts.
#
ln -s /usr/share/applications/org.keepassxc.KeePassXC.desktop $HOME/.config/autostart/

# Disable the VirtualBox web service. We don't need it, and it just
# likes to fail and make systemd complain anyway.
#
sudo systemctl disable vboxweb.service

# Add the current user to the vboxusers group. This is necessary to
# enable USB pass-through.
#
sudo usermod -aG vboxusers $USER

# Add the current user to the wireshark group. This is necessary to
# allow for packet capture without root privileges.
#
sudo usermod -aG wireshark $USER

# Generate new GPG key.
#
echo ""
echo "Create a GPG key for this device. Use the following settings:"
echo ""
echo ""
echo "    * When asked what kind of key you want to use, choose \"(9) ECC and"
echo "      ECC\"."
echo "    * When asked what kind of elliptic curve you want to use, choose \"(1)"
echo "      Curve 25519\"."
echo "    * When asked how long this key should be valid for, choose echo \"0\" (e.g.,"
echo "      \"key does not expire\")."
echo "    * Real name is \"Nathan Acks\", email address is"
echo "      \"nathan.acks@cardboard-iguana.com\", and the comment is today's date"
echo "      in YYYY-MM-DD format."
echo "" 
gpg --expert --full-generate-key
echo ""
echo "Add this GPG key to GitHub before continuing!"
read -p "Press any key to continue... " -n1 -s

# Restore all git repos.
#
mkdir $HOME/Repos
(
	git config --global user.name "Nathan Acks"
	git config --global user.email nathan.acks@cardboard-iguana.com
	git config --global user.signingKey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	git config --global commit.gpgSign true
	git config --global pull.rebase false
	cd $HOME/Repos
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yakcollective
	git clone git@github.com:necopinus/cardboard-iguana.com.git
	git clone git@github.com:necopinus/chateaumaxmin.info.git
	git clone git@github.com:necopinus/delphi-strategy.com.git
	git clone git@github.com:necopinus/digital-orrery.com.git
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@github.com:necopinus/ecopunk.info.git
	git clone git@github.com:necopinus/ellen-and-nathan.info.git
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	git clone git@github.com:The-Yak-Collective/lunchtime-tickets.git
	git clone git@github.com:necopinus/necopinus.xyz.git
	git clone git@github.com:The-Yak-Collective/onboarding_robot.git
	git clone git@github.com:The-Yak-Collective/project_ui.git
	git clone git@github.com:necopinus/resume.git
	git clone https://github.com/danielmiessler/SecLists.git
	git clone git@github.com:necopinus/website-theme.git
	git clone git@github.com:The-Yak-Collective/yakcollective.git
	git clone git@github.com:necopinus/zibaldone.git
)

# Finish up.
#
echo "A reboot is required for some features to become available."
