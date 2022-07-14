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

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications.
#
sudo apt install \
brave-browser \
fonts-noto \
keepassxc \
qalc \
virtualbox-ext-pack \
virtualbox-guest-additions-iso

flatpak install --user flathub org.signal.Signal

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

# Restore scripts and configurations from this repo.
#
mkdir -p $HOME/.config/autostart $HOME/.local/bin

cp $CONFIG_PATH/user/bash_aliases               $HOME/.bash_aliases
cp $CONFIG_PATH/user/inputrc                    $HOME/.inputrc
cp $CONFIG_PATH/user/local/bin/backup.sh        $HOME/.local/bin/backup.sh
cp $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh

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

# Restore select git repos.
#
mkdir $HOME/Repos
(
	cd $HOME/Repos
	git clone https://github.com/necopinus/dotfiles.git
)

# Finish up.
#
echo "A reboot is required for some features to become available."
