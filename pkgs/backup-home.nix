{writeShellApplication}:
writeShellApplication {
  name = "backup-home";

  text = ''
    set -e

    if [[ -z "$XDG_CONFIG_HOME" ]]; then
      export XDG_CONFIG_HOME="$HOME/.config"
    fi
    # shellcheck disable=SC1091
    source "$XDG_CONFIG_HOME/user-dirs.dirs"

    BACKUP_LIST="$(mktemp)"
    BACKUP_LIST_TMP="$(mktemp)"

    function mkBackupList {
        if [[ -d "$1" ]]; then
          find "$1" -type f -o \( -type d -empty \) -not \( \
               -name ".DS_Store" \
            -o -name ".localized" \
            -o -name "*.pyc" \
            -o -name "*.swp" \
            -o -name "*~" \
            -o -name ".#*" \
            -o -name "._*" \
          \) | sed "s#^$HOME/##g" >> "$BACKUP_LIST"
        elif [[ -f "$1" ]]; then
          # shellcheck disable=SC2001
          echo "$1" | sed "s#^$HOME/##g" >> "$BACKUP_LIST"
        fi
    }

    mkBackupList "$XDG_CONFIG_HOME/nix"

    mkBackupList "$HOME/.gnupg"
    mkBackupList "$HOME/.ssh"
    mkBackupList "$XDG_CONFIG_HOME/git/gpg.ini"
    mkBackupList "$XDG_CONFIG_HOME/shodan/api_key"
    mkBackupList "$XDG_CONFIG_HOME/api-keys.env.sh"

    mkBackupList "$HOME/.cddb"
    mkBackupList "$HOME/.dvdcss"
    mkBackupList "$XDG_CONFIG_HOME/aacs"

    if [[ "$(uname -s)" == "Linux" ]]; then
      mkBackupList "$HOME/data"
    else
      mkBackupList "$HOME/data/calibre"
    fi

    mkBackupList "$HOME/Library/Preferences/calibre"
    mkBackupList "$XDG_CONFIG_HOME/calibre"

    mkBackupList "$XDG_CONFIG_HOME/BraveSoftware"
    mkBackupList "$HOME/Library/Application Support/BraveSoftware"

    cat "$BACKUP_LIST" | sort -u > "$BACKUP_LIST_TMP"
    mv "$BACKUP_LIST_TMP" "$BACKUP_LIST"

    (
      cd "$HOME"
      tar -cJv -f "$XDG_DOWNLOAD_DIR/backup.tar.xz" -T "$BACKUP_LIST"
    )

    rm -f "$BACKUP_LIST"
  '';
}
