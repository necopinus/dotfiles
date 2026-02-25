{
  writeShellApplication,
  gnugrep,
  gnutar,
  uutils-coreutils-noprefix,
  uutils-findutils,
}:
writeShellApplication {
  name = "backup-home";

  runtimeInputs = [
    gnugrep
    gnutar
    uutils-coreutils-noprefix
    uutils-findutils
  ];

  text = ''
    # Set OS type
    #
    OS="$(uname -s)"

    # shellcheck disable=SC1091
    #source "$XDG_CONFIG_HOME/user-dirs.dirs"

    BACKUP_LIST="$(mktemp)"
    BACKUP_LIST_TMP="$(mktemp)"

    function mkBackupList {
        if [[ -d "$1" ]]; then
          find "$1" \( \
            \( -type f -o \( -type d -empty \) \) \
            -not \( -name ".DS_Store" \
                 -o -name ".localized" \
                 -o -name "*.pyc" \
                 -o -name "*.swp" \
                 -o -name "*~" \
                 -o -name ".#*" \
                 -o -name "._*" \) \
          \) -exec realpath "{}" \; | tee -a "$BACKUP_LIST"
        elif [[ -f "$1" ]]; then
          realpath "$1" | tee -a "$BACKUP_LIST"
        fi
    }

    mkBackupList "$XDG_CONFIG_HOME/nix"

    mkBackupList "$HOME/.ssh"
    mkBackupList "$XDG_CONFIG_HOME/shodan/api_key"

    mkBackupList "$HOME/.claude"
    mkBackupList "$HOME/.claude.json"
    mkBackupList "$HOME/Library/Application Support/Claude"

    mkBackupList "$HOME/.cddb"
    mkBackupList "$HOME/.dvdcss"
    mkBackupList "$XDG_CONFIG_HOME/aacs"
    mkBackupList "$XDG_CONFIG_HOME/adept"

    if [[ "$OS" == "Linux" ]]; then
      mkBackupList "$HOME/data"
    else
      mkBackupList "$HOME/data/calibre"
      mkBackupList "$HOME/Documents"
    fi

    mkBackupList "$XDG_CONFIG_HOME/engagements"

    mkBackupList "$HOME/Library/Preferences/calibre"
    mkBackupList "$XDG_CONFIG_HOME/calibre"

    mkBackupList "$HOME/Library/Application Support/obsidian"
    mkBackupList "$XDG_CONFIG_HOME/obsidian"

    mkBackupList "$XDG_CONFIG_HOME/BraveSoftware"
    mkBackupList "$HOME/Library/Application Support/BraveSoftware"

    mkBackupList "$XDG_CONFIG_HOME/chromium"
    mkBackupList "$HOME/Library/Application Support/Chromium"

    grep "^$HOME/" "$BACKUP_LIST" | sed "s#^$HOME/##g" | sort -u > "$BACKUP_LIST_TMP"
    mv "$BACKUP_LIST_TMP" "$BACKUP_LIST"

    (
      cd "$HOME"
      echo ""
      echo "=== Creating backup archive ==="
      echo ""
      tar -cJv -f "$XDG_DOWNLOAD_DIR/backup.tar.xz" -T "$BACKUP_LIST"
    )

    rm -f "$BACKUP_LIST"
  '';
}
