#!/usr/bin/env bash

# Install/update Zoom. Note that there's not an easy way to tell what
# the current version of Zoom is, so we just always grab the latest DEB.
#
BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://zoom.us/client/latest/zoom_amd64.deb
	sudo apt install ./zoom_amd64.deb
)
rm -rf "$BUILD_DIR"
