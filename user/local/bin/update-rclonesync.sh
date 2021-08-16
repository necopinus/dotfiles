#!/usr/bin/env bash

# Unfortunately, rclonesync doesn't tag a latest release.
#
# Fortunately, it's just a single Python 3 script.
#
mkdir -p $HOME/.local/bin
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://raw.githubusercontent.com/cjnaz/rclonesync-V2/master/rclonesync
	mkdir -p $HOME/.local/bin
	mv rclonesync $HOME/.local/bin/rclonesync
	chmod +x $HOME/.local/bin/rclonesync
)
rm -rf "$BUILD_DIR"
