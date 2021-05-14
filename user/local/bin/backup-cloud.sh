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

# Backup code repos.
#
if [[ -d $HOME/Code ]]; then
	find $HOME/Code -mindepth 1 -maxdepth 1 -type d -print0 | \
	while read -d '' GIT_DIR; do
		(
			cd "$GIT_DIR"
			git add -A -v
			git commit -m "Commit all changes before backup pull"
			git pull
			if [[ $(git config --get remote.origin.url | grep -cE '^http') -eq 0 ]]; then
				git push
			fi
		)
	done
	(
		cd $HOME/Code
		find . -mindepth 1 -maxdepth 1 -type d -exec tar -cvf "{}.tar" "{}" \;
		mkdir -p $BACKUP_PATH/Code
		mv -v *.tar $BACKUP_PATH/Code/
	)
fi

# Obsidian backups.
#
if [[ -d $HOME/Documents/TPIN ]]; then
	(
		cd $HOME/Documents
		mkdir -p $HOME/Downloads
		rm -f $HOME/Downloads/TPIN-Obsidian.zip
		zip -r $HOME/Downloads/TPIN-Obsidian.zip TPIN "TPIN - Large File Backup"
	)
fi
if [[ -d $HOME/OneDrive/DelphiStrategy/Zibaldone ]]; then
	(
		cd $HOME/OneDrive/DelphiStrategy
		mkdir -p $HOME/Downloads
		rm -f $HOME/Downloads/Obsidian.zip
		zip -r $HOME/Downloads/Obsidian.zip Zibaldone "Zibaldone - Large File Backup"
		mkdir -p $HOME/OneDrive/EcoPunk/Documents/Backups
		mv $HOME/Downloads/Obsidian.zip $HOME/OneDrive/EcoPunk/Documents/Backups/Obsidian.zip
	)
fi

# Backup VirtualBox.
#
#if [[ -d $HOME/VirtualBox ]]; then
#	rsync -av --delete --force --human-readable --progress $HOME/VirtualBox/ $BACKUP_PATH/VirtualBox/
#fi

# Warn on files not backed up to OneDrive...
#
echo ""
echo "The following files are NOT backed up to OneDrive:"
echo ""
find $HOME -type f -not -ipath "$HOME/.*" -not -ipath "$HOME/Code/*" -not -ipath "$HOME/go/*" -not -ipath "$HOME/OneDrive/*" -not -ipath "$HOME/Proton/*" -not -ipath "$HOME/VirtualBox/*"
