#!/usr/bin/env bash

# Set backup path.
#
BACKUP_PATH=$HOME/Documents/Backups
if [[ ! -d $BACKUP_PATH ]]; then
	echo "Backup path $BACKUP_PATH does not exist!"
	exit 1
fi

# Import backup password and backup GAM configuration.
#
if [[ -f $HOME/.config/backup-password ]]; then
	source $HOME/.config/backup-password
fi
if [[ -d $HOME/.gam ]] && [[ -n "$BACKUP_PASSWORD" ]] && [[ "$BACKUP_PASSWORD" != "XXX"  ]]; then
	(
		cd $HOME
		tar -cvf - .gam | 7z a -p$BACKUP_PASSWORD -si GAM.tar.7z
		mv -v GAM.tar.7z $BACKUP_PATH/
	)
fi

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
			if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
				 git push
			fi
			cd ..
		done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
	)
fi

# Update Google Drive local mirror.
#
if [[ -d $HOME/GoogleDrive ]] && [[ -f $HOME/.config/rclone/rclone.conf ]]; then
	rclone sync --drive-acknowledge-abuse --exclude /xdg-user-dirs/** --fast-list --progress --verbose google:/ $HOME/GoogleDrive/
fi

# Sync user data directories.
#
if [[ -f $HOME/.config/rclone/rclone.conf ]] && [[ -d $HOME/.rclonesyncwd ]]; then
	[[ -d $HOME/Desktop   ]] && rclonesync google:/xdg-user-dirs/Desktop/   $HOME/Desktop/   --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Documents ]] && rclonesync google:/xdg-user-dirs/Documents/ $HOME/Documents/ --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Downloads ]] && rclonesync google:/xdg-user-dirs/Downloads/ $HOME/Downloads/ --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Music     ]] && rclonesync google:/xdg-user-dirs/Music/     $HOME/Music/     --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Pictures  ]] && rclonesync google:/xdg-user-dirs/Pictures/  $HOME/Pictures/  --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Public    ]] && rclonesync google:/xdg-user-dirs/Public/    $HOME/Public/    --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Templates ]] && rclonesync google:/xdg-user-dirs/Templates/ $HOME/Templates/ --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
	[[ -d $HOME/Videos    ]] && rclonesync google:/xdg-user-dirs/Videos/    $HOME/Videos     --check-access --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --drive-acknowledge-abuse --fast-list
fi
