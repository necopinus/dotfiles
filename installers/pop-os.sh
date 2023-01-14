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

# Make sure all components are up-to-date.
#
source $CONFIG_PATH/user/local/bin/update-system.sh

# Install new applications.
#
sudo apt install \
virtualbox-ext-pack \
virtualbox-guest-additions-iso \
vlc

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
cp $CONFIG_PATH/user/local/bin/update.sh        $HOME/.local/bin/update.sh
cp $CONFIG_PATH/user/local/bin/update-system.sh $HOME/.local/bin/update-system.sh

chmod 755 $HOME/.local/bin/*

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
