#!/usr/bin/env sh

# Provides: OS, FLAVOR, ARCH, XDG_*_HOME, XDG_*_DIR, XDG_RUNTIME_DIR

# Grab OS information
# 
# `uname` is a surprising bottleneck, so we try to only call it once
#
UNAME="$(uname -s -m | tr '[:upper:]' '[:lower:]')"

# Set: OS, FLAVOR
#
UNAME_S="$(echo "$UNAME" | cut -d " " -f 1)"
if [[ "$UNAME_S" == "darwin" ]]; then
	OS="macos"
	FLAVOR="macos"
elif [[ "$UNAME_S" == "linux" ]]; then
	OS="linux"
	if [[ "$PREFIX" == "/data/data/com.termux/files/usr" ]]; then
		FLAVOR="termux"
	elif [[ -f /etc/os-release ]]; then
		if [[ $(grep -ic '^ID=debian$' /etc/os-release) -gt 0 ]]; then
			FLAVOR="debian"
		else
			FLAVOR="unsupported"
		fi
	else
		FLAVOR="unsupported"
	fi
else
	OS="unsupported"
	FLAVOR="unsupported"
fi
export OS FLAVOR
unset UNAME_S

# Set: ARCH
#
UNAME_M="$(echo "$UNAME" | cut -d " " -f 2)"
if [[ "$UNAME_M" == "aarch64" ]] || [[ "$UNAME_M" == "arm64" ]]; then
	ARCH="aarch64"
elif [[ "$UNAME_M" == "amd64" ]] || [[ "$UNAME_M" == "x86_64" ]]; then
	ARCH="amd64"
else
	ARCH="unsupported"
fi
export ARCH
unset UNAME_M

# Get rid of UNAME variable
#
unset UNAME

# Set: XDG_*_HOME
#
export XDG_CACHE_HOME="$HOME/cache"
export XDG_CONFIG_HOME="$HOME/config"
export XDG_DATA_HOME="$HOME/local/share"
export XDG_STATE_HOME="$HOME/local/state"

# Set XDG user directories
#
if [[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]]; then
	source "$XDG_CONFIG_HOME/user-dirs.dirs"
fi

# Make sure that $XDG_CACHE_HOME/env exists
#
# Set: XDG_RUNTIME_DIR
#
if [[ -z "$XDG_RUNTIME_DIR" ]]; then
	if [[ -d "/run/user/$UID" ]]; then
		XDG_RUNTIME_DIR="/run/user/$UID"
	else
		XDG_RUNTIME_DIR="$HOME/local/run"
	fi
	export XDG_RUNTIME_DIR
fi

# Make sure that XDG_CACHE_HOME/env, XDG_RUNTIME_DIR, and XDG_STATE_HOME
# directories exist and have the right permissions, if locally managed
#
mkdir -p $XDG_CACHE_HOME/env 2> /dev/null

if [[ "$XDG_RUNTIME_DIR" =~ ^$HOME/.* ]]; then
	if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
		mkdir -p "$XDG_RUNTIME_DIR" 2> /dev/null
	fi
	chmod 700 "$XDG_RUNTIME_DIR" 2> /dev/null
fi

if [[ ! -d "$XDG_STATE_HOME" ]]; then
	mkdir -p "$XDG_STATE_HOME" 2> /dev/null
fi
chmod 700 "$XDG_STATE_HOME" 2> /dev/null
