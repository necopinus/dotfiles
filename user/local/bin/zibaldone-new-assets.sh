#!/usr/bin/env bash

ASSETS_LIVE="$HOME/OneDrive/DelphiStrategy/Zibaldone/📦 Assets"
ASSETS_BACK="$HOME/OneDrive/DelphiStrategy/Zibaldone (Original 📦 Assets)"

while IFS= read -d '' -r FILE; do
	FILE_NAME="$(basename "$FILE")"
	if [[ ! -f "$ASSETS_BACK/$FILE_NAME" ]]; then
		echo "$FILE_NAME"
	fi
done < <(find "$ASSETS_LIVE" -type f -print0)
