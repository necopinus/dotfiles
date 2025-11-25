#!/usr/bin/env bash

if [[ "$(uname -s)" != "Linux" ]]; then
	echo "for some reason, pip2nix only works on Linux."
	echo ""
	echo "https://github.com/nix-community/pip2nix/issues/88"
	exit 1
else
	nix run github:nix-community/pip2nix -- generate -r requirements.txt
fi
