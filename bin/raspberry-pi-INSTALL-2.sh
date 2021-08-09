#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Set backup path.
#
BACKUP_PATH=$HOME/OneDrive/Documents/Backups
if [[ ! -d $BACKUP_PATH ]]; then
	echo "Backup path $BACKUP_PATH does not exist!"
	exit 1
fi

# Confirm that we've finished part 1.
#
echo "This script should *only* be run after OneDrive has been fully synced"
echo "to this machine. IF THIS STEP IS NOT YET FINISHED USE CTRL+C TO EXIT"
echo "NOW!"
echo ""
read -p "Press any key to continue... " -n1 -s
echo ""

# Set up symlinks (safely).
#
[[ -d $HOME/OneDrive/Desktop   ]] && rm -rf $HOME/Desktop   && ln -s $HOME/OneDrive/Desktop   $HOME/Desktop
[[ -d $HOME/OneDrive/Documents ]] && rm -rf $HOME/Documents && ln -s $HOME/OneDrive/Documents $HOME/Documents
[[ -d $HOME/OneDrive/Downloads ]] && rm -rf $HOME/Downloads && ln -s $HOME/OneDrive/Downloads $HOME/Downloads
[[ -d $HOME/OneDrive/Music     ]] && rm -rf $HOME/Music     && ln -s $HOME/OneDrive/Music     $HOME/Music
[[ -d $HOME/OneDrive/Pictures  ]] && rm -rf $HOME/Pictures  && ln -s $HOME/OneDrive/Pictures  $HOME/Pictures
[[ -d $HOME/OneDrive/Public    ]] && rm -rf $HOME/Public    && ln -s $HOME/OneDrive/Public    $HOME/Public
[[ -d $HOME/OneDrive/Templates ]] && rm -rf $HOME/Templates && ln -s $HOME/OneDrive/Templates $HOME/Templates
[[ -d $HOME/OneDrive/Videos    ]] && rm -rf $HOME/Videos    && ln -s $HOME/OneDrive/Videos    $HOME/Videos

# Restore Obsidian data.
#
if [[ -d $BACKUP_PATH/Obsidian ]]; then
	rm -rf $HOME/Obsidian
	cp -apvrf $BACKUP_PATH/Obsidian $HOME/Obsidian
	rm -rf $HOME/Obsidian/*\ -\ Large\ File\ Backup
fi
