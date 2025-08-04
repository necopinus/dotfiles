# Personal dotfiles

My dotfiles + a setup script for quickly configuring a new device. Currently only supports macOS and Termux; Debian (Android VM) support currently exists in aspirational (untested, probably broken) form.

You don't want to use these files directly, as they hard-code certain aspects of my setup (username, etc.). They are provided publicly as a potential source of information for folks and/or examples of how to sove various problems with cross-OS dotfiles.

Current iteration heavily inspired by [Drew DeVault](https://drewdevault.com/2019/12/30/dotfiles.html).

## Quick start

```bash
if [[ -n "$PREFIX" ]] && [[ -n "$(which pkg 2> /dev/null)" ]]; then
    pkg install git
fi

git clone --bare https://github.com/necopinus/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
./local/lib/common/libexec/setup
```

## License ("MIT")

Copyright (c) Nathan Acks

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

