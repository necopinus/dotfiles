#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/obsidian ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/obsidian)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/obsidianmd/obsidian-releases/releases/download/v${REMOTE_VERSION}/Obsidian-${REMOTE_VERSION}.AppImage
		mkdir -p $HOME/.local/bin
		mv Obsidian-${REMOTE_VERSION}.AppImage $HOME/.local/bin/obsidian
		chmod +x $HOME/.local/bin/obsidian
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/obsidian
	)
	rm -rf "$BUILD_DIR"
else
	echo "Obsidian is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/obsidian
fi
