#!/usr/bin/env bash

if [[ -f /etc/os-release ]]; then
	source /etc/os-release
fi

if [[ -n "$(which brew)" ]]; then
	brew update
	brew upgrade
	brew autoremove
	brew cleanup -s
elif [[ -n "$(which apt)" ]]; then
	if [[ "$ID" == "kali" ]] && [[ "$(uname -m)" == "aarch64" ]]; then
		sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 11764EE8AC24832F
	fi
	sudo apt update
	sudo apt full-upgrade
	sudo apt autoremove --purge --autoremove
	sudo apt clean
fi

if [[ -d /etc/skel ]]; then
	while IFS= read -d '' -r SKEL_DIR; do
		HOME_DIR="$(echo "$SKEL_DIR" | sed -e "s#^/etc/skel#$HOME#")"
		mkdir -p "$HOME_DIR"
	done < <(find /etc/skel -mindepth 1 -type d -print0)

	while IFS= read -d '' -r SKEL_FILE; do
		HOME_FILE="$(echo "$SKEL_FILE" | sed -e "s#^/etc/skel#$HOME#")"
		cp -apf "$SKEL_FILE" "$HOME_FILE"
	done < <(find /etc/skel -type f -print0)
fi

if [[ -n "$(which flatpak)" ]]; then
	flatpak update
	flatpak uninstall --unused
fi

if [[ "$ID" == "kali" ]] && [[ "$(uname -m)" == "aarch64" ]] && [[ -f /boot/initramfs.zst ]]; then
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
	KERNEL_VERSION=$(ls -1 /lib/modules | grep -e '-Re4son-v8l+$' | sort | tail -1)
	if [[ -f /usr/src/linux-headers-$KERNEL_VERSION/.config ]]; then
		sudo cp /usr/src/linux-headers-$KERNEL_VERSION/.config /boot/config-$KERNEL_VERSION
	fi
	if [[ -f /boot/initramfs.bak.zst ]]; then
		sudo mv /boot/initramfs.bak.zst /boot/initramfs.bak-prev.zst
	fi
	if [[ -f /boot/initramfs.zst ]]; then
		sudo mv /boot/initramfs.zst /boot/initramfs.bak.zst
	fi
	sudo mkinitramfs -v -o /boot/initramfs.zst $KERNEL_VERSION
fi
