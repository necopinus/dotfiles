#!/usr/bin/env bash

BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-linux.AppImage
	mkdir -p $HOME/.local/bin
	mv yubikey-manager-qt-latest-linux.AppImage $HOME/.local/bin/yubikey-manager
	chmod +x $HOME/.local/bin/yubikey-manager
)
rm -rf "$BUILD_DIR"
