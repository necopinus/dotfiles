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
if [[ "$BACKUP_FS" != "exfat" ]] && [[ "$BACKUP_FS" != "fuseblk" ]] && [[ "$BACKUP_FS" != "ext4" ]]; then
	echo "Expected $BACKUP_PATH to be an external exFAT or ext4 file system."
	echo "Please ensure the backup vault is mounted and functioning properly."
	exit 1
fi

# Make sure that code repos are all up-to-date.
#
if [[ -d $HOME/Code ]]; then
	CODE_ROOT=$HOME/Code
elif [[ -d $HOME/code ]]; then
	CODE_ROOT=$HOME/code
else
	CODE_ROOT="N/A"
fi
if [[ "$CODE_ROOT" != "N/A" ]]; then
	(
		cd $CODE_ROOT
		while IFS= read -r -d '' OBJECT; do
			cd "$OBJECT"
			git pull
			if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
				 git push
			fi
			cd ..
		done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
	)
fi

# Mirror Yak Collective Roam backup into Google Drive.
#
if [[ "$CODE_ROOT" != "N/A" ]] && [[ -d "$CODE_ROOT/backups-yak-collective/Roam" ]] && [[ -d "$HOME/Yak Collective/Backups" ]]; then
	rsync -av --delete --force --human-readable --progress $CODE_ROOT/backups-yak-collective/Roam/ $HOME/"Yak Collective"/Backups/Roam/
fi

# The backup, which is really just mirroring content.
#
# NOTE: Once the Re4son Raspberry Pi kernel that Kali Linux uses is
# upgraded to 4.9+, it shouldn't be necessary to use exfat-fuse anymore
# and the fuseblk stanza here (and test above) can be dropped. (It
# might also make sense to uninstall exfat-utils and exfat-fuse at that
# time in favor of the exfatprogs package that's supported by Samsung.)
#
if [[ "$BACKUP_FS" = "exfat" ]]; then
	(
		cd $HOME
		while IFS= read -r -d '' OBJECT; do
			if [[ -d "$OBJECT" ]] && [[ "$OBJECT" != "./Code" ]] && [[ "$OBJECT" != "./code" ]]; then
				rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/"$OBJECT"/ $BACKUP_PATH/"$OBJECT"/
			elif [[ -f "$OBJECT" ]]; then
				rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/"$OBJECT"  $BACKUP_PATH/"$OBJECT"
			fi
		done < <(find . -mindepth 1 -maxdepth 1 -not -ipath './.*' -print0)
	)
elif [[ "$BACKUP_FS" = "fuseblk" ]]; then
	(
		cd $HOME
		while IFS= read -r -d '' OBJECT; do
			if [[ -d "$OBJECT" ]] && [[ "$OBJECT" != "./Code" ]] && [[ "$OBJECT" != "./code" ]]; then
				rsync -vrltD --checksum --delete --force --human-readable --no-times --progress $HOME/"$OBJECT"/ $BACKUP_PATH/"$OBJECT"/
			elif [[ -f "$OBJECT" ]]; then
				rsync -vrltD --checksum --delete --force --human-readable --no-times --progress $HOME/"$OBJECT"  $BACKUP_PATH/"$OBJECT"
			fi
		done < <(find . -mindepth 1 -maxdepth 1 -not -ipath './.*' -print0)
	)
elif [[ "$BACKUP_FS" = "ext4" ]]; then
	mkdir -p $BACKUP_PATH/$HOSTNAME
	rsync -av --delete --force --human-readable --progress $HOME/ $BACKUP_PATH/$HOSTNAME/
fi
