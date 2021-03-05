#!/usr/bin/env bash

VERSION="1.1.5"

BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-${VERSION}-linux.AppImage
	curl -L -O https://raw.githubusercontent.com/Yubico/yubikey-manager-qt/master/ykman-gui/images/windowicon.png
	mkdir -p $HOME/.local/bin $HOME/.local/share/icons
	mv yubikey-manager-qt-${VERSION}-linux.AppImage ~/.local/bin/ykman.AppImage
	mv windowicon.png ~/.local/share/icons/ykman.png
	chmod 755 ~/.local/bin/ykman.AppImage
)
rm -rf "$BUILD_DIR"

