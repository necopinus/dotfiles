#!/usr/bin/env bash

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

# Backup GAM configuration.
#
if [[ -d $HOME/.gam ]]; then
	(
		cd $HOME
		tar -cvf - .gam | 7z a -p$BACKUP_PASSWORD -si GAM.tar.7z
		mv -v GAM.tar.7z $BACKUP_PATH/
	)
fi

# Backup Proton Technologies data and configuration.
#
if [[ -d $HOME/Proton ]]; then
	(
		cd $HOME
		$HOME/Proton/.bin/backup.sh
		tar -cvf - .config/hydroxide Proton | 7z a -p$BACKUP_PASSWORD -si ProtonTechnologies.tar.7z
		mv -v ProtonTechnologies.tar.7z $BACKUP_PATH/
	)
fi

# Backup SSH configuration.
#
if [[ -d $HOME/.ssh ]]; then
	(
		cd $HOME
		tar -cvf - .ssh | 7z a -p$BACKUP_PASSWORD -si SSH.tar.7z
		mv -v SSH.tar.7z $BACKUP_PATH/
	)
fi

# Backup code repos.
#
if [[ -d $HOME/Code ]]; then
	(
		cd $HOME/Code
		find . -mindepth 1 -maxdepth 1 -type d -exec tar -cvf "{}.tar" "{}" \;
		mkdir -p $BACKUP_PATH/Code
		mv -v *.tar $BACKUP_PATH/Code/
	)
fi

# Backup VirtualBox.
#
if [[ -d $HOME/VirtualBox ]]; then
	rsync -av --delete --force --human-readable --progress $HOME/VirtualBox/ $BACKUP_PATH/VirtualBox/
fi
