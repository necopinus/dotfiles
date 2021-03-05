#!/usr/bin/env bash

BUILD_DIR="$(mktemp -d)"
(
	cd "$BUILD_DIR"
	git clone https://github.com/emersion/hydroxide.git
	cd hydroxide
	GO111MODULE=on go build ./cmd/hydroxide
	mkdir -p $HOME/.local/bin
	mv hydroxide $HOME/.local/bin/hydroxide
)
rm -rf "$BUILD_DIR"

