#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/hydroxide ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/hydroxide)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/emersion/hydroxide/releases | grep -Po '"tag_name": ?"v\K.*?(?=")' | head -1)"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		git clone https://github.com/emersion/hydroxide.git
		cd hydroxide
		git checkout v${REMOTE_VERSION}
		GO111MODULE=on go build ./cmd/hydroxide
		mkdir -p $HOME/.local/bin
		mv hydroxide $HOME/.local/bin/hydroxide
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/hydroxide
	)
	rm -rf "$BUILD_DIR"
else
	echo "Hydroxide is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/hydroxide
fi


