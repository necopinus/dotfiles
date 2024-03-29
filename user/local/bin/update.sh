#!/usr/bin/env bash

UPDATE_PATH=$HOME/.local/bin

[[ -x $UPDATE_PATH/update-system.sh ]] && $UPDATE_PATH/update-system.sh

[[ -x $UPDATE_PATH/update-ligolo.sh ]] && $UPDATE_PATH/update-ligolo.sh
[[ -x $UPDATE_PATH/update-ngrok.sh  ]] && $UPDATE_PATH/update-ngrok.sh

# Make sure that Git repos are all up-to-date.
#
if [[ -d $HOME/Repos ]] && [[ "$(whoami)" != "root" ]]; then
	(
		cd $HOME/Repos
		while IFS= read -r -d '' REPO; do
			if [[ -d $REPO/.git ]]; then
				cd "$REPO"
				git pull --recurse-submodules
				if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
					 git push --recurse-submodules=on-demand
				fi
				cd ..
			fi
		done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
	)
fi
