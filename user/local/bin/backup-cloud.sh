#!/usr/bin/env bash

# Set backup path.
#
BACKUP_PATH=$HOME/OneDrive/Documents/Backups
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
if [[ -z "$BACKUP_PASSWORD" ]] || [[ "$BACKUP_PASSWORD" == "XXX"  ]]; then
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
		tar -cvf - Proton | 7z a -p$BACKUP_PASSWORD -si ProtonTechnologies.tar.7z
		mv -v ProtonTechnologies.tar.7z $BACKUP_PATH/
	)
fi

# Backup Obsidian.
#
if [[ -d $HOME/Obsidian ]]; then
	mkdir -p $BACKUP_PATH/Obsidian
	(
		cd $HOME/Obsidian
		find . -mindepth 1 -maxdepth 1 -type d -exec rsync -av --delete --force --human-readable --progress "{}"/ $BACKUP_PATH/Obsidian/"{}"/ \;
		if [[ -d TPIN ]]; then
			[[ -f $HOME/Notes.zip ]] && rm -f $HOME/Notes.zip
			zip -r $HOME/Notes.zip TPIN
		fi
	)
fi

# Backup VirtualBox.
#
#if [[ -d $HOME/VirtualBox ]]; then
#	rsync -av --delete --force --human-readable --progress $HOME/VirtualBox/ $BACKUP_PATH/VirtualBox/
#fi

# Make sure that code repos are all up-to-date.
#
if [[ -d $HOME/Code ]]; then
	CODE_ROOT=$HOME/Code
elif [[ -d $HOME/code ]]; then
	CODE_ROOT=$HOME/code
else
	CODE_ROOT=""
fi
if [[ -n "$CODE_ROOT" ]]; then
	(
		cd $CODE_ROOT
		while IFS= read -r -d '' OBJECT; do
			cd "$OBJECT"
			git pull
			git push
			cd ..
		done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
	)
fi
