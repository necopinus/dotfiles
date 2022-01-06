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

if [[ "$HOSTNAME" != "Nathans-iPad" ]] && [[ -n "$(which ruby)" ]] && [[ -n "$(which gem)" ]]; then
	gem update --user-install
fi

if [[ -n "$(which flatpak)" ]]; then
	flatpak update
	flatpak uninstall --unused
fi

if [[ "$HOSTNAME" == "kali" ]] && [[ "$(uname -m)" == "aarch64" ]] && [[ -f /boot/initramfs.gz ]]; then
	if [[ ! -f /boot/overlays/dwc2.dtbo ]] && [[ $(ls -1 /lib/modules | grep -e '5.4.83-Re4son-v8l+$' | wc -l) -gt 0 ]]; then
		BUILD_DIR="$(mktemp -d)"
		(
			cd "$BUILD_DIR"
			curl -L -O https://raw.githubusercontent.com/Re4son/re4son-raspberrypi-linux/rpi-5.4.83-re4son/arch/arm/boot/dts/overlays/dwc2-overlay.dts
			dtc -o dwc2.dtbo dwc2-overlay.dts
			sudo mv dwc2.dtbo /boot/overlays/dwc2.dtbo
		)
		rm -rf "$BUILD_DIR"
	fi
	sudo mkinitramfs -o /boot/initramfs.gz $(ls -1 /lib/modules | grep -e '-Re4son-v8l+$' | sort | tail -1)
fi
