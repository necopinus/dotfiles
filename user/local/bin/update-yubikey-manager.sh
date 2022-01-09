#!/usr/bin/env bash

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
)
rm -rf "$BUILD_DIR"
