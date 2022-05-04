# Dotfiles

Various configuration files & scripts.

## iSH

```shell
apk add bash git
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/installers/*
./dotfiles/installers/ish.sh
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
	./dotfiles/bin/kali-linux-virtualbox.sh
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
