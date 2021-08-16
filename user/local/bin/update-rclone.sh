#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/rclone ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/rclone)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Get system architecture.
#
UNAME_ARCH="$(uname -m)"
if [[ "$UNAME_ARCH" == "x86_64" ]]; then
	ARCH="amd64"
elif [[ "$UNAME_ARCH" == "aarch64" ]]; then
	ARCH="arm64"
else
	ARCH="xxxxx"
	echo "Unknown architecture: $UNAME_ARCH"
fi


# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]] && [[ "$ARCH" != "xxxxx" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/rclone/rclone/releases/download/v${REMOTE_VERSION}/rclone-v${REMOTE_VERSION}-linux-${ARCH}.deb
		sudo apt install ./rclone-v${REMOTE_VERSION}-linux-${ARCH}.deb
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/gam
	)
	rm -rf "$BUILD_DIR"
else
	echo "rclone is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/rclone
fi
