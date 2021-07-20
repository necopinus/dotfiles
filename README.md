# Dotfiles

Various configuration files & scripts.

## Pop!_OS on the System76 Darter Pro 5

1. Clone repo and run the first stage configuration. The system will be
   rebooted when this is done.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/bin/*
	./dotfiles/bin/darter-pro-INSTALL-1.sh
	```

2. Get a full sync of OneDrive. This can take a while, and be a bit
   twitchy (if possible, it's better/faster to restore
   `~/.cache/onedrive`, `~/.config/onedrive`, and `~/OneDrive` from a
   local backup).

	```bash
	onedrive --synchronize --verbose --resync
	```

3. Run the second stage configuration.

	```bash
	~/_setup/dotfiles/bin/darter-pro-INSTALL-2.sh
	```

4. Set up KeePassXC, `~/.config/backup-password`, and new per-device
   SSH/GPG keys.

5. Run the third stage configuration and clean up the `~/_setup`
   directory.

	```bash
	~/_setup/dotfiles/bin/darter-pro-INSTALL-3.sh
	rm -rf ~/_setup
	```

6. Finish configuring applications.

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

4. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

5. Restart the Linux VM

6. Configure any graphical applications.
