# Personal dotfiles

My dotfiles + a setup script for quickly configuring a new device. Currently only supports macOS and Termux; Debian (Android VM) support currently exists in aspirational (untested, probably broken) form.

You don't want to use these files directly, as they hard-code certain aspects of my setup (username, etc.). They are provided publicly as a potential source of information for folks and/or examples of how to sove various problems with cross-OS dotfiles.

Current iteration heavily inspired by [Drew DeVault](https://drewdevault.com/2019/12/30/dotfiles.html).

## Quick start

```bash
git clone --bare https://github.com/necopinus/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
./local/lib/common/libexec/setup
```
