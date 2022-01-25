#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/radicle ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/radicle)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/radicle-dev/radicle-upstream/tags | grep -Po '"name": ?"v\K.*?(?=")' | head -1)"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://releases.radicle.xyz/radicle-upstream-${REMOTE_VERSION}.AppImage
		mv radicle-upstream-${REMOTE_VERSION}.AppImage radicle-upstream
		chmod +x radicle-upstream
		./radicle-upstream --appimage-extract radicle-upstream.desktop
		./radicle-upstream --appimage-extract usr/share/icons/hicolor/0x0/apps/radicle-upstream.png
		mkdir -p $HOME/.local/bin
		mv radicle-upstream $HOME/.local/bin/radicle-upstream
		mkdir -p $HOME/.local/share/icons
		mv squashfs-root/usr/share/icons/hicolor/0x0/apps/radicle-upstream.png $HOME/.local/share/icons/radicle-upstream.png
		mkdir -p $HOME/.local/share/applications
		sed -e "s#^Exec=.*#Exec=$HOME/.local/bin/radicle-upstream#" squashfs-root/radicle-upstream.desktop > $HOME/.local/share/applications/radicle-upstream.desktop
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/radicle
	)
	rm -rf "$BUILD_DIR"
else
	echo "Radicle is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/radicle
fi
