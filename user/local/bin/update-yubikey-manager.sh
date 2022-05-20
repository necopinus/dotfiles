#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/yubikey-manager ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/yubikey-manager)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/Yubico/yubikey-manager-qt/tags | grep -Po '"name": ?"yubikey-manager-qt-\K.*?(?=")' | head -1)"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-linux.AppImage
		mv yubikey-manager-qt-latest-linux.AppImage ykman-gui
		chmod +x ykman-gui
		./ykman-gui --appimage-extract ykman-gui.desktop
		./ykman-gui --appimage-extract ykman.png
		mkdir -p $HOME/.local/bin
		mv ykman-gui $HOME/.local/bin/ykman-gui
		mkdir -p $HOME/.local/share/icons
		mv squashfs-root/ykman.png $HOME/.local/share/icons/ykman.png
		mkdir -p $HOME/.local/share/applications
		sed -e "s#^Exec=.*#Exec=$HOME/.local/bin/ykman-gui#" squashfs-root/ykman-gui.desktop > $HOME/.local/share/applications/ykman-gui.desktop
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/yubikey-manager
	)
	rm -rf "$BUILD_DIR"
else
	echo "Yubikey Manager is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/yubikey-manager
fi
