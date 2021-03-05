#!/usr/bin/env bash

sudo apt update
sudo apt full-upgrade
sudo apt autoremove --purge --autoremove
sudo apt clean

flatpak update
flatpak uninstall --unused
