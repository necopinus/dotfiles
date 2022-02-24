#!/usr/bin/env bash

source /etc/os-release

if [[ "$ID" == "debian" ]]; then
	GLIBC_VERSION="2.27"
else
	GLIBC_VERSION="2.31"
fi

if [[ "$(uname -m)" == "aarch64" ]]; then
	ARCH="arm64"
else
	ARCH=x86_64
fi

# Get local version.
#
if [[ -f $HOME/.cache/versions/gam ]]; then
	LOCAL_VERSION="$(cat $HOME/.cache/versions/gam)"
else
	LOCAL_VERSION="XXX"
fi

# Get remote version.
#
REMOTE_VERSION="$(curl -L -s https://api.github.com/repos/taers232c/GAMADV-XTD3/releases/latest | grep -Po '"tag_name": ?"v\K.*?(?=")')"

# Install/update if there is a new version.
#
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	BUILD_DIR="$(mktemp -d)"
	(
		cd "$BUILD_DIR"
		curl -L -O https://github.com/taers232c/GAMADV-XTD3/releases/download/v${REMOTE_VERSION}/gamadv-xtd3-${REMOTE_VERSION}-linux-${ARCH}-glibc${GLIBC_VERSION}.tar.xz
		mkdir -p $HOME/.local/bin
		tar -xJf gamadv-xtd3-${REMOTE_VERSION}-linux-${ARCH}-glibc${GLIBC_VERSION}.tar.xz -C $HOME/.local/bin --strip-components=1 gamadv-xtd3/gam
		mkdir -p $HOME/.cache/versions
		echo "$REMOTE_VERSION" > $HOME/.cache/versions/gam
	)
	rm -rf "$BUILD_DIR"
else
	echo "GAM is already at v${REMOTE_VERSION}"
	touch $HOME/.cache/versions/gam
fi
