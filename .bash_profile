#!/usr/bin/env bash

# Make sure that ~/.profile is read
#
source $HOME/.profile

# Source ~/.bashrc if this is an interactive shell
#
if [[ $- == *i* ]]; then
	source $HOME/.bashrc
fi
