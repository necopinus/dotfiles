#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/kiterunner ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/kiterunner)"
else
	LOCAL_VERSION="XXX"
fi

# Determine architecture.
#
if [[ "$(uname -m)" == "aarch64" ]]; then
	ARCH="arm64"
else
	ARCH="amd64"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/assetnote/kiterunner/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/assetnote/kiterunner/releases/download/v${REMOTE_VERSION}/kiterunner_${REMOTE_VERSION}_linux_${ARCH}.tar.gz
		mkdir -p $HOME/.local/bin
		tar -xzf kiterunner_${REMOTE_VERSION}_linux_${ARCH}.tar.gz -C $HOME/.local/bin kr
		chmod +x $HOME/.local/bin/kr
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/kiterunner
	)
	rm -rf "$BUILD_DIR"
else
	echo "Kiterunner is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/kiterunner
fi
