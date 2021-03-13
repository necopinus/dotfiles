#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Set backup path.
#
BACKUP_PATH=$HOME/OneDrive/EcoPunk/Documents/Backups
if [[ ! -d $BACKUP_PATH ]]; then
	echo "Backup path $BACKUP_PATH does not exist!"
	exit 1
fi

# Import backup password.
#
if [[ -f $HOME/.config/backup-password ]]; then
	source $HOME/.config/backup-password
else
	echo "Backup password file $HOME/.config/backup-password does not exist!"
	exit 1
fi
if [[ -z "$BACKUP_PASSWORD" ]]; then
	echo "Backup password does not appear to be set!"
	exit 1
fi

# Confirm that we've finished part 1.
#
echo "This script should *only* be run after OneDrive has been fully synced"
echo "to this machine. IF A FULL INITIAL SYNC HAS NOT YET FINISHED USE CTRL+C"
echo "TO EXIT NOW!"
echo ""
read -p "Press any key to continue... " -n1 -s
echo ""

# Enable and start OneDrive sync processes.
#
systemctl --user enable onedrive@DelphiStrategy.service
systemctl --user enable onedrive@EcoPunk.service

systemctl --user start onedrive@DelphiStrategy.service
systemctl --user start onedrive@EcoPunk.service

# Extract GAM configuration.
#
if [[ -f $BACKUP_PATH/GAM.tar.7z ]]; then
	(
		cd $HOME
		rm -rf .gam
		7z x -p$BACKUP_PASSWORD -so $BACKUP_PATH/GAM.tar.7z | tar -xvf -
	)
fi

# Extract Proton Technologies data and configuration.
#
# If Hydroxide needs to be reauthenticated for some reason (for example,
# if some of the files in ~/.config/hydroxide are corrupt), then this
# can be done using:
#
#     hydroxide auth USER.NAME@protonmail.com
#
if [[ -f $BACKUP_PATH/ProtonTechnologies.tar.7z ]]; then
	(
		cd $HOME
		rm -rf Proton .config/hydroxide
		7z x -p$BACKUP_PASSWORD -so $BACKUP_PATH/ProtonTechnologies.tar.7z | tar -xvf -
		find .config/hydroxide -type d -exec chmod 700 "{}" \;
		find .config/hydroxide -type f -exec chmod 600 "{}" \;
		find Proton -type d -exec chmod 700 "{}" \;
		find Proton -type f -exec chmod 600 "{}" \;
		chmod 700 .config/hydroxide Proton Proton/.bin/backup.sh
	)
fi

# Extract SSH configuration.
#
if [[ -f $BACKUP_PATH/SSH.tar.7z ]]; then
	(
		cd $HOME
		rm -rf .ssh
		7z x -p$BACKUP_PASSWORD -so $BACKUP_PATH/SSH.tar.7z | tar -xvf -
	)
fi

# Restore all git repos.
#
mkdir -p $HOME/Code
(
	cd $HOME/Code
	git clone https://github.com/keeweb/keeweb.git
	mv keeweb app-keeweb
	GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null" git clone git@bitbucket.org:tpin-it-security/keeweb-overlay.git
	mv keeweb-overlay app-keeweb-overlay
	cd app-keeweb-overlay
	git config core.sshCommand "ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null"
	git config user.email "nathan.acks@publicinterestnetwork.org"
	cd ..
	GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null"git clone git@bitbucket.org:tpin-it-security/assets-okta.git
	cd assets-okta
	git config core.sshCommand "ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null"
	git config user.email "nathan.acks@publicinterestnetwork.org"
	cd ..
	GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null"git clone git@bitbucket.org:tpin-it-security/automation-it-lifecycle.git
	cd automation-it-lifecycle
	git config core.sshCommand "ssh -i $HOME/.ssh/id_ed25519_tpin -F /dev/null"
	git config user.email "nathan.acks@publicinterestnetwork.org"
	cd ..
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

# Restore VirtualBox data.
#
if [[ -d $BACKUP_PATH/VirtualBox ]]; then
	rm -rf $HOME/VirtualBox
	cp -apvrf $BACKUP_PATH/VirtualBox $HOME/VirtualBox
fi

# Enable Joplin autostart.
#
mkdir -p $HOME/.config/autostart
cp $CONFIG_PATH/user/config/autostart/joplin_autostart.desktop $HOME/.config/autostart/joplin_autostart.desktop

# Run the initial Keybase setup/configuration.
#
run_keybase
