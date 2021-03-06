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
# OneDrive, as those folders contain all of the data I care about.
# Otherwise, back up all of $HOME in order to capture additional
# configuration files (and potentially enable a full restore!).
#
BACKUP_FS="$(mount | grep $BACKUP_PATH | sed -e 's/ (.*$//;s/^.* type //')"
if [[ "$BACKUP_FS" != "exfat" ]] && [[ "$BACKUP_FS" != "ext4" ]]; then
	echo "Expected $BACKUP_PATH to be an external exFAT or ext4 file system."
	echo "Please ensure the backup vault is mounted and functioning properly."
	exit 1
fi

# Should we try to back up Keybase?
#
KEYBASE_MOUNTED="$(mount | grep -c $XDG_RUNTIME_DIR/keybase/kbfs)"

# The backup, which is really just mirroring content.
#
if [[ "$BACKUP_FS" = "exfat" ]]; then
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/OneDrive/DelphiStrategy/ $BACKUP_PATH/DelphiStrategy/
	rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $HOME/OneDrive/EcoPunk/        $BACKUP_PATH/EcoPunk/
	if [[ "$KEYBASE_MOUNTED" = "1" ]]; then
		rsync -vrltD --delete --force --human-readable --modify-window=1 --progress $XDG_RUNTIME_DIR/keybase/kbfs/ $BACKUP_PATH/KBFS/
	fi
else
	rsync -av --delete --force --human-readable --progress $HOME/ $BACKUP_PATH/home/
	if [[ "$KEYBASE_MOUNTED" = "1" ]]; then
		rsync -av --delete --force --human-readable --progress $XDG_RUNTIME_DIR/keybase/kbfs/ $BACKUP_PATH/kbfs/
		find $BACKUP_PATH/kbfs -type d -exec chmod 700 "{}" \;
		find $BACKUP_PATH/kbfs -type f -exec chmod 600 "{}" \;
	fi
fi
