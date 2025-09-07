#!/usr/bin/env bash

# Convenience function to make sure that our X session is *really* dead
#
function clean_up_x_session {
	TERMUX_ANDROID_USER=$(whoami)

	pkill --full pulseaudio

	pkill -9 dbus

	rm --recursive --force $PREFIX/../home/.config/pulse
	rm --recursive --force $PREFIX/tmp/dbus-*
	rm --recursive --force $PREFIX/tmp/*-${TERMUX_ANDROID_USER}
	rm --recursive --force $PREFIX/tmp/*-${TERMUX_ANDROID_USER}.*
	rm --recursive --force $PREFIX/tmp/*_${TERMUX_ANDROID_USER}
	rm --recursive --force $PREFIX/tmp/*-necopinus
	rm --recursive --force $PREFIX/tmp/*-necopinus.*
	rm --recursive --force $PREFIX/tmp/*_necopinus
	rm --recursive --force $PREFIX/tmp/*-kali
	rm --recursive --force $PREFIX/tmp/*-kali.*
	rm --recursive --force $PREFIX/tmp/*_kali
	rm --recursive --force $PREFIX/tmp/proot-*
	rm --recursive --force $PREFIX/tmp/pulse-*
	rm --recursive --force $PREFIX/var/run/dbus/pid
}

# Actual launch process
#
clean_up_x_session

source $HOME/.profile

dbus-daemon --system --fork --address=unix:path=$PREFIX/var/run/dbus/system_bus_socket

if [[ "$(getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]')" == "samsung" ]]; then
	env LD_PRELOAD=/system/lib64/libskcodec.so \
	pulseaudio --start \
               --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
               --exit-idle-time=-1
else
	pulseaudio --start \
	           --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
	           --exit-idle-time=-1
fi
export PULSE_SERVER=tcp:127.0.0.1

unset TERM TERM_PROGRAM TMUX TMUX_PANE
dbus-launch --exit-with-session awesome

clean_up_x_session
