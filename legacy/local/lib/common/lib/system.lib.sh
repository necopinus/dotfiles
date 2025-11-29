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
    if [[ -f /etc/os-release ]]; then
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

# Set XDG user directories
#
if [[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]]; then
    source "$XDG_CONFIG_HOME/user-dirs.dirs"
fi

# Make sure that XDG_STATE_HOME exists and has the right permissions
#
if [[ ! -d "$XDG_STATE_HOME" ]]; then
    mkdir -p "$XDG_STATE_HOME" 2>/dev/null
fi
chmod 700 "$XDG_STATE_HOME" 2>/dev/null
