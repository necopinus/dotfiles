# Dotfiles

Various configuration files & scripts.

## iSH

```bash
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

```bash
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/installers/*
./dotfiles/installers/kali-linux.sh
cd ..
rm -rf ~/_setup
```

Configure applicable GUI applications.

## Pop!\_OS

Set up new per-device SSH/GPG keys.

```bash
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/installers/*
./dotfiles/installers/pop-os.sh
cd ..
rm -rf ~/_setup
```

Configure applicable GUI applications.
