#!/usr/bin/env bash

VERSION="5.33"
GLIBC_VERSION="2.31"

BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	curl -L -O https://github.com/jay0lee/GAM/releases/download/v${VERSION}/gam-${VERSION}-linux-x86_64-glibc${GLIBC_VERSION}.tar.xz
	mkdir -p $HOME/.local/bin
	tar -xJf gam-${VERSION}-linux-x86_64-glibc${GLIBC_VERSION}.tar.xz -C $HOME/.local/bin --strip-components=1 gam/gam
)
rm -rf "$BUILD_DIR"

