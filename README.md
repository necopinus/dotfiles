# Dotfiles

Various configuration files & scripts.

## iSH

```bash
apk add bash git
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/installers/*
./dotfiles/installers/kali-linux.sh
cd ..
rm -rf ~/_setup
```

## Kali Linux

1. Clone repo and run the configuration script. The system will be
   rebooted when this is done.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/installers/*
	./dotfiles/installers/kali-linux.sh
	```

2. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

3. Finish configuring applications.

## Pop!_OS

1. Set up new per-device SSH/GPG keys.

2. Clone repo and run the first stage configuration. The system will be
   rebooted when this is done.

	```bash
	mkdir ~/_setup
	cd ~/_setup
	git clone https://github.com/necopinus/dotfiles.git
	chmod 755 dotfiles/installers/*
	./dotfiles/installers/darter-pro.sh
	```

3. Clean up the `~/_setup` directory.

	```bash
	rm -rf ~/_setup
	```

4. Finish configuring applications.
