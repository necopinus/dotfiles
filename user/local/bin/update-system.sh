#!/usr/bin/env bash

if [[ "$HOSTNAME" == "Nathans-iPad" ]] && [[ -n "$(which apk)" ]]; then
	apk update
	apk upgrade
elif [[ -n "$(which apt)" ]]; then
	sudo apt update
	sudo apt full-upgrade
	sudo apt autoremove --purge --autoremove
	sudo apt clean
fi

if [[ -n "$(which flatpak)" ]]; then
	flatpak update
	flatpak uninstall --unused
fi

if [[ "$HOSTNAME" == "kali" ]] && [[ "$(uname -m)" == "aarch64" ]] && [[ -f /boot/initramfs.gz ]]; then
	sudo mkinitramfs -o /boot/initramfs.gz $(ls -1 /lib/modules | grep -e '-Re4son-v8l+$' | sort | tail -1)
fi
