# Personal dotfiles

My dotfiles + a setup script for quickly configuring a new device. Currently only supports [macOS](https://www.apple.com/os/macos/) and [Debian](https://debian.org) VMs.

You don't want to use these files directly, as they hard-code certain aspects of my setup (username, etc.). They are provided publicly as a potential source of information for folks and/or examples of how to sove various problems with cross-OS dotfiles.

## Quick start

> [!important]
> Debian VMs that are *not* the Android VM need to be set up in a specific fashion in order to be compatible with the `init.sh` setup script:
>
> 1. The primary user *must* be named `droid`.
> 2. It is *recommended* (but not *required*) that no desktop environment be installed initially (`init.sh` will create a *minimal* GNOME installation automatically).
> 3. Once the initial installation is complete the following additional setup must be performed:
>
> 	```bash
> 	# NOTE: The actual directories and user mappings below may vary. The
> 	# important parts are that:
> 	#
> 	#   1. A directory is shared from the host that contains a set of
> 	#      subdirectories matching(ish) the default XDG user directories.
> 	#      This can just be the host's $HOME, or could be a special
> 	#      directory on the host specifically created for this purpose.
> 	#
> 	#   2. The permissions in the shared directory need to match (or be
> 	#      mapped to) the user/group permissions of the `droid` user. In
> 	#      the exammple below, a bindfs mount is used to accomplish this
> 	#      for a host directory with common macOS permissions.
> 	#
> 	#   3. The *final* directory that is used to reference host files
> 	#      from the guest must be located at /mnt/shared.
> 	
> 	sudo apt install -y bindfs
> 	
> 	sudo mkdir /mnt/utm /mnt/shared
> 	
> 	sudo tee -a /etc/fstab <<EOF
> 	share    /mnt/utm    9p          trans=virtio,version=9p2000.L,rw,_netdev,nofail,auto                   0 0
> 	/mnt/utm /mnt/shared fuse.bindfs map=501/1000:@20/@1000,x-systemd.requires=/mnt/utm,_netdev,nofail,auto 0 0
> 	EOF
> 	
> 	sudo shutdown -r now
> 	```

> [!important]
> On macOS, you _must_ grant your terminal application the "Full Disk Access" privilege in order for the commands below to work.

```bash
if [[ -n "$(which apt 2> /dev/null)" ]]; then
    sudo apt install git
elif [[ -n "$(which xcode-select 2> /dev/null)" ]]; then
	xcode-select --install || true

	until $(xcode-select -p &> /dev/null); do
		sleep 4;
	done
fi

cd $HOME

mkdir -p $HOME/.config
git clone git@github.com:necopinus/dotfiles.git $HOME/.config/nix

$HOME/.config/nix/init.sh
```
