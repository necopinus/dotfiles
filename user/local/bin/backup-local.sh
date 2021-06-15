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
# our XDG_DATA directories, as those folders contain all of the data
# I really care about. Otherwise, back up all of $HOME in order to
# capture additional configuration files (and potentially enable a
# full restore!).
#
BACKUP_FS="$(mount | grep $BACKUP_PATH | sed -e 's/ (.*$//;s/^.* type //')"
if [[ "$BACKUP_FS" != "exfat" ]] && [[ "$BACKUP_FS" != "ext4" ]]; then
	echo "Expected $BACKUP_PATH to be an external exFAT or ext4 file system."
	echo "Please ensure the backup vault is mounted and functioning properly."
	exit 1
fi

# The backup, which is really just mirroring content.
#
if [[ "$BACKUP_FS" = "exfat" ]]; then
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Desktop/   $BACKUP_PATH/Desktop/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Documents/ $BACKUP_PATH/Documents/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Downloads/ $BACKUP_PATH/Downloads/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Music/     $BACKUP_PATH/Music/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Pictures/  $BACKUP_PATH/Pictures/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Public/    $BACKUP_PATH/Public/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Templates/ $BACKUP_PATH/Templates/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/Videos/    $BACKUP_PATH/Videos/
else
	rsync -avx --delete --force --human-readable --progress $HOME/ $BACKUP_PATH/home/
fi
