#!/usr/bin/env bash

# Backup function
#
function backupVault {
	# Vault & backup name
	#
	VAULT_SRC="$1"
	VAULT_BAK="$(basename "$1")"

	# Make sure that backup destination exits
	#
	BACKUP_ROOT="$HOME/.local/share/obsidian-backups/$VAULT_BAK"
	mkdir -p "$BACKUP_ROOT"

	# Previous and next backups
	#
	BACKUP_NEXT=$(date "+%Y-%m-%d-%H-%M-%S")
	BACKUP_PREV=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -regextype sed -regex ".*/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}" -exec basename "{}" \; | sort -u | tail -1)

	# Backup Obsidian vault
	#
	if [[ -z "$BACKUP_PREV" ]]; then
		cp -apvrf "$VAULT_SRC" "$BACKUP_ROOT"/$BACKUP_NEXT
	else
		cp -aprf --link "$BACKUP_ROOT"/$BACKUP_PREV "$BACKUP_ROOT"/$BACKUP_NEXT
		rsync -av --delete --force --human-readable --progress "$VAULT_SRC"/ "$BACKUP_ROOT"/$BACKUP_NEXT/
	fi
}

# Backups
#
if [[ -d $HOME/Documents/TPIN ]]; then
	backupVault $HOME/Documents/TPIN
	(
		cd $HOME/Documents
		mkdir -p $HOME/Downloads
		rm -rf $HOME/Downloads/TPIN-Obsidian.zip
		zip -qr $HOME/Downloads/TPIN-Obsidian.zip TPIN
	)
fi
if [[ -d $HOME/OneDrive/DelphiStrategy/Zibaldone ]]; then
	backupVault $HOME/OneDrive/DelphiStrategy/Zibaldone
fi
