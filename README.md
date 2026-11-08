# Personal dotfiles

My dotfiles and a setup script for configuring a new device or VM. It currently
supports [macOS](https://www.apple.com/os/macos/) and [exe.dev](https://exe.dev/).

These files hard-code parts of my setup, including usernames. They are provided
publicly as examples for solving cross-OS dotfile problems. You should not use
them directly.

## Quick start

> [!important]
> On macOS, you _must_ grant Terminal.app (before running `init.sh`) and
> Termius.app (after running `init.sh`) the "Full Disk Access" privilege.

```bash
if [[ -n "$(which apt 2> /dev/null)" ]]; then
    sudo apt install git
elif [[ -n "$(which xcode-select 2> /dev/null)" ]]; then
    xcode-select --install || true

    until xcode-select -p &>/dev/null; do
        sleep 4;
    done
fi

cd $HOME

mkdir -p $HOME/.config
git clone https://github.com/necopinus/dotfiles.git "$HOME/.config/nix"

bash "$HOME/.config/nix/init.sh"

# After adding the generated public key to GitHub:
git -C "$HOME/.config/nix" remote set-url origin git@github.com:necopinus/dotfiles.git
```
