#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/deskreen ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/deskreen)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/pavlobu/deskreen/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/pavlobu/deskreen/releases/download/v${REMOTE_VERSION}/Deskreen-${REMOTE_VERSION}.AppImage
		mkdir -p $HOME/.local/bin
		mv Deskreen-${REMOTE_VERSION}.AppImage $HOME/.local/bin/deskreen
		chmod +x $HOME/.local/bin/deskreen
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/deskreen
	)
	rm -rf "$BUILD_DIR"
else
	echo "Deskreen is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/deskreen
fi
