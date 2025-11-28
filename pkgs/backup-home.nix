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

    # FIXME: This command probably needs significant modification to
    #        exclude symlinks into the nix store
    #
    tar -cJv --exclude=.DS_Store \
             --exclude=.localized \
             --exclude="S.*" \
             --exclude="*.pyc" \
             --exclude="*.swp" \
             --exclude="*~" \
             --exclude=".#*" \
        -f "$XDG_DOWNLOAD_DIR/backup.tar.xz" -T - << EOF
    $(test -d .gnupg && echo ".gnupg")
    $(test -d .ssh && echo ".ssh")
    $(test -d .cddb && echo ".cddb")
    $(test -d .dvdcss && echo ".dvdcss")
    $(test -d "$XDG_CONFIG_HOME/aacs" && echo "$XDG_CONFIG_HOME/aacs" | sed "s#$HOME/##")
    $(test -f "$XDG_CONFIG_HOME/shodan/api_key" && echo "$XDG_CONFIG_HOME/shodan/api_key" | sed "s#$HOME/##")
    $(test -f "$XDG_CONFIG_HOME/api-keys.env.sh" && echo "$XDG_CONFIG_HOME/api-keys.env.sh" | sed "s#$HOME/##")
    $(test -d "data/calibre" && echo "data/calibre")
    $(test -d "Library/Preferences/calibre" && echo "Library/Preferences/calibre")
    $(test -d "$XDG_CONFIG_HOME/calibre" && echo "$XDG_CONFIG_HOME/calibre" | sed "s#$HOME/##")
    $(test -d "$XDG_CONFIG_HOME/BraveSoftware" && echo "$XDG_CONFIG_HOME/BraveSoftware" | sed "s#$HOME/##")
    $(test -d "Library/Application Support/BraveSoftware" && echo "Library/Application Support/BraveSoftware")
    $(test -f "$XDG_CONFIG_HOME/git/gpg.ini" && echo "$XDG_CONFIG_HOME/git/gpg.ini" | sed "s#$HOME/##")
    $(test -d "$XDG_CONFIG_HOME/nix" && echo "$XDG_CONFIG_HOME/nix" | sed "s#$HOME/##")
    EOF
  '';
}
