#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/kerbrute ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/kerbrute)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/ropnop/kerbrute/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	if [[ "$(uname -m)" == "x86_64" ]]; then
		BUILD_DIR="$(mktemp -d)"
		(
			cd "$BUILD_DIR"
			curl -L -O https://github.com/ropnop/kerbrute/releases/download/v${REMOTE_VERSION}/kerbrute_linux_amd64
			mkdir -p $HOME/.local/bin
			mv kerbrute_linux_amd64 $HOME/.local/bin/kerbrute
			chmod +x $HOME/.local/bin/kerbrute
		)
		rm -rf "$BUILD_DIR"
	else
		go install github.com/ropnop/kerbrute@v${REMOTE_VERSION}
	fi	
	mkdir -p $HOME/.cache/versions
	echo "$REMOTE_VERSION" > $HOME/.cache/versions/kerbrute
else
	echo "Kerbrute is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/kerbrute
fi
