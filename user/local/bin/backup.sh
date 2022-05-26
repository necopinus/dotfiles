#!/usr/bin/env bash

BACKUP_PATH=/media/$USER/Vault

# Make sure that backup vault is mounted.
#
if [[ ! -d $BACKUP_PATH ]]; then
	echo "No local backup vault found!"
	exit 1
fi

# Determine *which* backup vault we're using. If it's the exFAT vault
# then we can't backup symlinks, etc. In this case, we just backup
# user data. Otherwise, back up all of $HOME in order to capture
# additional configuration files (and potentially enable a full
# restore!).
#
BACKUP_FS="$(mount | grep $BACKUP_PATH | sed -e 's/ (.*$//;s/^.* type //')"
if [[ "$BACKUP_FS" != "exfat" ]] && [[ "$BACKUP_FS" != "ext4" ]]; then
	echo "Expected $BACKUP_PATH to be an external exFAT or ext4 file system."
	echo "Please ensure the backup vault is mounted and functioning properly."
	exit 1
fi

# Make sure that Git repos are all up-to-date.
#
if [[ -d $HOME/Repos ]]; then
	(
		cd $HOME/Repos
		while IFS= read -r -d '' OBJECT; do
			if [[ -d $OBJECT/.git ]]; then
				cd "$OBJECT"
				git pull
				if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
					 git push
				fi
				cd ..
			fi
		done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
	)
fi

# Mirror Yak Collective Roam backup into Google Drive.
#
if [[ -d "$HOME/Repos/backups-yakcollective/Roam" ]] && [[ -d "$HOME/Repos/yakcollective/Backups" ]]; then
	rsync -av --delete --force --human-readable --progress $HOME/Repos/backups-yakcollective/Roam/ $HOME/Repos/yakcollective/Backups/Roam/
fi

# The backup, which is really just mirroring content.
#
if [[ "$BACKUP_FS" = "exfat" ]]; then
	(
		cd $HOME
		while IFS= read -r -d '' OBJECT; do
			if [[ -d "$OBJECT" ]]; then
				rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/"$OBJECT"/ $BACKUP_PATH/"$OBJECT"/
			elif [[ -f "$OBJECT" ]]; then
				rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/"$OBJECT"  $BACKUP_PATH/"$OBJECT"
			fi
		done < <(find . -mindepth 1 -maxdepth 1 -not -ipath './.*' -print0)
	)
elif [[ "$BACKUP_FS" = "ext4" ]]; then
	mkdir -p $BACKUP_PATH/$HOSTNAME
	rsync -av --delete --force --human-readable --progress $HOME/ $BACKUP_PATH/$HOSTNAME/
	if [[ -d $BACKUP_PATH/../BOOT ]] && [[ -d $BACKUP_PATH/../ROOTFS ]]; then
		sudo rsync -av --delete --force --human-readable --progress $BACKUP_PATH/../BOOT/ $BACKUP_PATH/kali/BOOT/
		sudo rsync -av --delete --force --human-readable --progress $BACKUP_PATH/../ROOTFS/ $BACKUP_PATH/kali/ROOTFS/
	fi
fi
