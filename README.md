# Dotfiles

Various configuration files & scripts.

## iSH

```shell
apk add bash git
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/bin/*
./dotfiles/bin/ish-INSTALL.sh
cd ..
rm -rf ~/_setup
```

## Kali Linux on the Raspberry Pi 4B

1. Set up new per-device SSH/GPG keys.

2. Clone repo and run the first stage configuration. The system will be
   rebooted when this is done.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/bin/*
	./dotfiles/bin/raspberry-pi-INSTALL.sh
	```

3. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

4. Configure `insync-headless` for all of my accounts:

	```bash
	# Add Google account. To get an auth code, go to:
	#
	#     https://insynchq.com/auth?cloud=gd
	#
	insync-headless account add --auth-code $AUTH_CODE --cloud gd --path $SYNC_PATH --export-options MS_OFFICE

	# Turn on sync for all files.
	#
	env TERM=xterm insync-headless selective-sync

	# Repeat the above for each account...

	insync-headless subscription show
	#
	# Go to heeps://insynchq.com/dashboard to update the
	# machine ID.
	#
	insync-headless subscription refresh
	```

5. Finish configuring applications.

## Chrome OS

1. Install the Linux developer environment.

2. Set up new per-device SSH/GPG keys.

3. Clone repo and run the configuration script.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/bin/*
	./dotfiles/bin/chrome-os-INSTALL.sh
	```

4. Restart the Linux VM

5. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

6. Configure any graphical applications.

## Pop!_OS on the System76 Darter Pro 5

1. Set up new per-device SSH/GPG keys.

2. Clone repo and run the first stage configuration. The system will be
   rebooted when this is done.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/bin/*
	./dotfiles/bin/darter-pro-INSTALL.sh
	```

3. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

4. Configure Insync for all of my accounts.

5. Finish configuring applications.
