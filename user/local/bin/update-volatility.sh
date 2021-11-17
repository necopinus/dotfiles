#!/usr/bin/env bash

# Volatility requires PyCryptodome, but for some reason doesn't pick up
# the system-level version provided by Kali. It *does* pick up a
# manually installed version though.
#
pip install --user --upgrade pycryptodome

# Install/update Volatility (Python 3 rewrite).
#
pip install --user --upgrade volatility3
