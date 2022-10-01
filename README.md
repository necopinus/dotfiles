# Dotfiles

Various configuration files & scripts.

## macOS

```bash
xcode-select --install
sudo softwareupdate --install-rosetta
mkdir ~/_setup
cd ~/_setup
git clone https://github.com/necopinus/dotfiles.git
chmod 755 dotfiles/installers/*
./dotfiles/installers/macos.sh
cd ..
rm -rf ~/_setup
```

Configure applicable GUI applications and distribute SSH/GPG keys.

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
