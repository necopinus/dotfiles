#!/usr/bin/env bash

UPDATE_PATH=$HOME/.local/bin

[[ -x $UPDATE_PATH/update-system.sh          ]] && $UPDATE_PATH/update-system.sh

[[ -x $UPDATE_PATH/update-zoom.sh            ]] && $UPDATE_PATH/update-zoom.sh
[[ -x $UPDATE_PATH/update-gam.sh             ]] && $UPDATE_PATH/update-gam.sh
[[ -x $UPDATE_PATH/update-youtube-dl.sh      ]] && $UPDATE_PATH/update-youtube-dl.sh
[[ -x $UPDATE_PATH/update-yubikey-manager.sh ]] && $UPDATE_PATH/update-yubikey-manager.sh
[[ -x $UPDATE_PATH/update-keybase.sh         ]] && $UPDATE_PATH/update-keybase.sh
[[ -x $UPDATE_PATH/update-volatility.sh      ]] && $UPDATE_PATH/update-volatility.sh
[[ -x $UPDATE_PATH/update-obsidian.sh        ]] && $UPDATE_PATH/update-obsidian.sh
