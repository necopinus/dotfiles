#!/usr/bin/env bash

# Get local version.
#
if [[ -f $HOME/.cache/versions/keybase ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/keybase)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/keybase/client/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# FIXME: Lock Keybase version until issue 24479 is resolved.
#
REMOTE_VERSION="5.7.1"

# Get system architecture.
#
UNAME_ARCH="$(uname -m)"
if [[ "$UNAME_ARCH" == "x86_64" ]]; then
	export KEYBASE_SKIP_32_BIT=1
elif [[ "$UNAME_ARCH" == "aarch64" ]]; then
	export KEYBASE_BUILD_ARM_ONLY=1
else
	echo "Unknown architecture: $UNAME_ARCH"
	exit 1
fi

# Install/update if there is a new version.
#
# Note that "production" ONLY builds the keybase command line binary.
# The GUI does not currently build on aarch64 because of a problem
# downloading an appropriate version of Electron. There's an unmerged
# pull request to fix this; see:
#
#     https://github.com/keybase/client/issues/23605
#     https://github.com/keybase/client/pull/24242
#
# Once this is resolved, building the GUI and KBFS will also require the
# installation of the following packages:
#
#     libfuse3-dev
#     libgtk2.0-dev (replace with GTK3 once Electron is updated?)
#     libxss-dev
#     npm
#
# It will also be necessary to install the "yarn" package via NPM and
# change the build flag to "prerelease".
#
# (KBFS and the GUI will also require additional service files to be
# installed...)
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		git clone https://github.com/keybase/client
		cd client
		git checkout v${REMOTE_VERSION}
		./packaging/linux/build_binaries.sh production build_dir
		mkdir -p $HOME/.local/bin
		mv build_dir/binaries/arm64/usr/bin/keybase $HOME/.local/bin/keybase
		mkdir -p $HOME/.config/systemd/user/default.target.wants
		sed -e 's#/usr/bin/keybase#%h/.local/bin/keybase#' packaging/linux/systemd/keybase.service > $HOME/.config/systemd/user/keybase.service
		ln -sf $HOME/.config/systemd/user/keybase.service $HOME/.config/systemd/user/default.target.wants/keybase.service
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/keybase
		echo "Keybase updated to v${REMOTE_VERSION}. A reboot is STRONGLY recommended."
	)
	rm -rf "$BUILD_DIR"
else
	echo "Keybase is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/keybase
fi

# Unset Keybase build variables.
#
unset KEYBASE_SKIP_32_BIT KEYBASE_BUILD_ARM_ONLY
