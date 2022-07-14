#!/usr/bin/env bash

UPDATE_PATH=$HOME/.local/bin

[[ -x $UPDATE_PATH/update-system.sh          ]] && $UPDATE_PATH/update-system.sh

[[ -x $UPDATE_PATH/update-kerbrute.sh        ]] && $UPDATE_PATH/update-kerbrute.sh
[[ -x $UPDATE_PATH/update-kiterunner.sh      ]] && $UPDATE_PATH/update-kiterunner.sh
[[ -x $UPDATE_PATH/update-ngrok.sh           ]] && $UPDATE_PATH/update-ngrok.sh
