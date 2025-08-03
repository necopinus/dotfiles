#!/usr/bin/env bash

DISTRO_NAME="Kali NetHunter"
DISTRO_COMMENT="A free and open-source mobile penetration testing platform for Android devices."
TARBALL_URL['aarch64']="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
TARBALL_SHA256['aarch64']="{{tarball-sha256}}"

distro_setup() {
	# Install base system
	#
	run_proot_cmd env DEBIAN_FRONTEND=noninteractive apt update       --quiet --assume-yes --fix-missing
	run_proot_cmd env DEBIAN_FRONTEND=noninteractive apt full-upgrade --quiet --assume-yes --fix-broken

	run_proot_cmd env DEBIAN_FRONTEND=noninteractive apt install --quiet --assume-yes \
		build-essential \
		dialog \
		kali-nethunter-core \
		kali-nethunter-full \
		tmux \
		xsel

	run_proot_cmd env DEBIAN_FRONTEND=noninteractive apt autoremove --quiet --assume-yes --purge --autoremove
	run_proot_cmd env DEBIAN_FRONTEND=noninteractive apt clean      --quiet --assume-yes

	# Make sure locale is built
	#
	sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' ./etc/locale.gen
	run_proot_cmd env DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

	# Generate local self-signed certificate (for PostgreSQL)
	#
	run_proot_cmd env DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil
	chmod 600 ./etc/ssl/private/ssl-cert-snakeoil.key

	# Add additional groups to the default user
	#
	run_proot_cmd usermod --append --groups adm,audio,cdrom,dialout,dip,floppy,netdev,plugdev,sudo,staff,users,video kali
}
