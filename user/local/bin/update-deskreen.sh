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
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/pavlobu/deskreen/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/pavlobu/deskreen/releases/download/v${REMOTE_VERSION}/Deskreen-${REMOTE_VERSION}.AppImage
		mv Deskreen-${REMOTE_VERSION}.AppImage deskreen
		chmod +x deskreen
		./deskreen --appimage-extract deskreen.desktop
		./deskreen --appimage-extract usr/share/icons/hicolor/1024x1024/apps/deskreen.png
		mkdir -p $HOME/.local/bin
		mv deskreen $HOME/.local/bin/deskreen
		mkdir -p $HOME/.local/share/icons
		mv squashfs-root/usr/share/icons/hicolor/1024x1024/apps/deskreen.png $HOME/.local/share/icons/deskreen.png
		mkdir -p $HOME/.local/share/applications
		sed -e "s#^Exec=.*#Exec=$HOME/.local/bin/deskreen#" squashfs-root/deskreen.desktop > $HOME/.local/share/applications/deskreen.desktop
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/deskreen
	)
	rm -rf "$BUILD_DIR"
else
	echo "Deskreen is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/deskreen
fi
