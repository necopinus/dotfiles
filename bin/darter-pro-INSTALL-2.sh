#!/usr/bin/env bash

# Get the path to this script, so that we can correctly find relevant
# dotfiles.
#
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
CONFIG_PATH="$(dirname "$SCRIPT_PATH")/../"

# Confirm that we've finished part 1.
#
echo "This script should *only* be run after rclone has been configured and."
echo "device SSH and GPG keys have been created. IF THESE STEPS HAVE NOT YET"
echo "BEEN COMPLETED, USE CTRL+C TO EXIT NOW!"
echo ""
read -p "Press any key to continue... " -n1 -s
echo ""

# Create backup directory for Google Drive and pull initial mirror.
#
mkdir -p $HOME/GoogleDrive
rclone sync --bwlimit 8500k --drive-acknowledge-abuse --exclude /xdg-user-dirs/** --fast-list --progress --verbose google:/ $HOME/GoogleDrive/

# Sync actual user data directories.
#
rclonesync google:/xdg-user-dirs/Desktop/   $HOME/Desktop/   --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Documents/ $HOME/Documents/ --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Downloads/ $HOME/Downloads/ --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Music/     $HOME/Music/     --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Pictures/  $HOME/Pictures/  --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Public/    $HOME/Public/    --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Templates/ $HOME/Templates/ --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list
rclonesync google:/xdg-user-dirs/Videos/    $HOME/Videos     --first-sync --max-deletes 5 --rc-verbose --remove-empty-directories --rclone-args --bwlimit 8500k --drive-acknowledge-abuse --fast-list

# Restore all git repos.
#
mkdir -p $HOME/Code
(
	git config --global user.email nathan.acks@cardboard-iguana.com
	git config --global user.signingkey "$(gpg --list-keys nathan.acks@cardboard-iguana.com | grep -E "^      [0-9A-Z]{40}$" | sed -e "s/^ *//")"
	cd $HOME/Code
	git clone git@github.com:The-Yak-Collective/onboarding_robot.git
	mv onboarding_robot automation-onboarding-robot
	git clone git@github.com:The-Yak-Collective/project_ui.git
	mv project_ui automation-project-ui
	git clone git@github.com:necopinus/backups.git
	mv backups backups-necopinus
	git clone git@github.com:The-Yak-Collective/backups.git
	mv backups backups-yak-collective
	git clone git@github.com:The-Yak-Collective/infrastructure-map.git
	mv infrastructure-map doc-infrastructure-map
	git clone git@github.com:necopinus/dotfiles.git
	git clone git@bitbucket.org:necopinus/hugo-theme-story.git
	git clone git@bitbucket.org:necopinus/website-chateaumaxmin.info.git
	git clone git@bitbucket.org:necopinus/website-delphi-strategy.com.git
	git clone git@bitbucket.org:necopinus/website-digital-orrery.com.git
	git clone git@bitbucket.org:necopinus/website-ecopunk.info.git
	git clone git@github.com:The-Yak-Collective/yakcollective.git
	mv yakcollective website-yakcollective.org
)
