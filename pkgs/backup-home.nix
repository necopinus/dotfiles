{writeShellApplication}:
writeShellApplication {
  name = "backup-home";

  text = ''
    set -e

    cd "$HOME"

    if [[ -z "$XDG_CONFIG_HOME" ]]; then
      export XDG_CONFIG_HOME="$HOME/.config"
    fi
    # shellcheck disable=SC1091
    source "$XDG_CONFIG_HOME/user-dirs.dirs"

    tar -cJv --exclude=".DS_Store" \
             --exclude=".localized" \
             --exclude="*.pyc" \
             --exclude="*.swp" \
             --exclude="*~" \
             --exclude=".#*" \
             --exclude="._*" \
        -f "$XDG_DOWNLOAD_DIR/backup.tar.xz" -T - << EOF
    $(test -d "$HOME/.gnupg" && find "$HOME/.gnupg" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/.ssh" && find "$HOME/.ssh" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/.cddb" && find "$HOME/.cddb" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/.dvdcss" && find "$HOME/.dvdcss" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$XDG_CONFIG_HOME/aacs" && find "$XDG_CONFIG_HOME/aacs" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/data/calibre" && find "data/calibre" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/Library/Preferences/calibre" && find "Library/Preferences/calibre" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$XDG_CONFIG_HOME/calibre" && find "$XDG_CONFIG_HOME/calibre" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$XDG_CONFIG_HOME/BraveSoftware" && find "$XDG_CONFIG_HOME/BraveSoftware" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$HOME/Library/Application Support/BraveSoftware" && find "Library/Application Support/BraveSoftware" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")
    $(test -d "$XDG_CONFIG_HOME/nix" && find "$XDG_CONFIG_HOME/nix" -type f -o \( -type d -empty \) | sed "s#^$HOME/##g")

    $(test -f "$XDG_CONFIG_HOME/shodan/api_key" && echo "$XDG_CONFIG_HOME/shodan/api_key" | sed "s#^$HOME/##g")
    $(test -f "$XDG_CONFIG_HOME/api-keys.env.sh" && echo "$XDG_CONFIG_HOME/api-keys.env.sh" | sed "s#^$HOME/##g")
    $(test -f "$XDG_CONFIG_HOME/git/gpg.ini" && echo "$XDG_CONFIG_HOME/git/gpg.ini" | sed "s#^$HOME/##g")
    EOF
  '';
}
