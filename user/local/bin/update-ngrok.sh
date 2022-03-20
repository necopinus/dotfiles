#!/usr/bin/env bash

# Determine architecture.
#
if [[ "$(uname -m)" == "aarch64" ]]; then
	ARCH="arm64"
else
	ARCH="amd64"
fi

# Always update.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-${ARCH}.tgz
	mkdir -p $HOME/.local/bin
	tar -xzf ngrok-stable-linux-${ARCH}.tgz -C $HOME/.local/bin ngrok
	chmod +x $HOME/.local/bin/ngrok
)
rm -rf "$BUILD_DIR"
