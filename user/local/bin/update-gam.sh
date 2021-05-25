#!/usr/bin/env bash

GLIBC_VERSION="2.31"

# Get local version.
#
if [[ -f $HOME/.cache/versions/gam ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/gam)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -s https://api.github.com/repos/jay0lee/GAM/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/jay0lee/GAM/releases/download/v${REMOTE_VERSION}/gam-${REMOTE_VERSION}-linux-x86_64-glibc${GLIBC_VERSION}.tar.xz
		mkdir -p $HOME/.local/bin
		tar -xJf gam-${REMOTE_VERSION}-linux-x86_64-glibc${GLIBC_VERSION}.tar.xz -C $HOME/.local/bin gam
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/gam
	)
	rm -rf "$BUILD_DIR"
else
	echo "GAM is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/gam
fi

