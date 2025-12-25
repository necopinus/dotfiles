# Personal dotfiles

My dotfiles + a setup script for quickly configuring a new device. Currently only supports macOS and Debian (specifically the Android VM).

You don't want to use these files directly, as they hard-code certain aspects of my setup (username, etc.). They are provided publicly as a potential source of information for folks and/or examples of how to sove various problems with cross-OS dotfiles.

## Quick start

> [!important]
> On macOS, you _must_ grant your terminal application the "Full Disk Access" privilege in order for the commands below to work. After `init.sh` finishes its run, you _must_ also grant this privilege to WezTerm!

```bash
if [[ -n "$(which apt 2> /dev/null)" ]]; then
    sudo apt install git
elif [[ -n "$(which xcode-select 2> /dev/null)" ]]; then
	xcode-select --install || true

	until $(xcode-select --print-path &> /dev/null); do
		sleep 4;
	done
fi

cd $HOME

mkdir -p $HOME/config
git clone git@github.com:necopinus/dotfiles.git $HOME/config/nix

$HOME/config/nix/init.sh
```
