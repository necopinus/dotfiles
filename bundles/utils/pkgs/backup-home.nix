{writeShellApplication}:
writeShellApplication {
  name = "backup-home";

  text = ''
    BACKUP_LIST="$(mktemp)"
    BACKUP_LIST_TMP="$(mktemp)"

    function mkBackupList {
      if [[ -d "$1" ]]; then
        echo "Adding files: $1 ..."
        find "$1" \( \
          \( -type f -o \( -type d -empty \) \) \
          -not \( -name ".DS_Store" \
               -o -name ".localized" \
               -o -name "*.pyc" \
               -o -name "*.db-wal" \
               -o -name "*.db-shm" \
               -o -name "*.db-journal" \
               -o -name "*.swp" \
               -o -name "*~" \
               -o -name ".#*" \
               -o -name "._*" \) \
        \) -exec realpath "{}" \; >> "$BACKUP_LIST"
      elif [[ -f "$1" ]]; then
        echo "Adding file:  $1 ..."
        realpath "$1" >> "$BACKUP_LIST"
      fi
    }

    if [[ "$(hostname)" == "kitsune" ]]; then
      hermes backup
      crontab -l > "$HOME/exedev.crontab"
      if [[ -d "$HOME/grimoire" ]]; then
        npx --package=obsidian-headless -- ob sync --path "$HOME/grimoire"
      fi
      if [[ -d "$HOME/journal" ]]; then
        npx --package=obsidian-headless -- ob sync --path "$HOME/journal"
      fi
      if [[ -d "$HOME/research" ]]; then
        npx --package=obsidian-headless -- ob sync --path "$HOME/research"
      fi
    fi

    mkBackupList "$XDG_CONFIG_HOME/nix"

    mkBackupList "$HOME/.ssh"
    mkBackupList "$HOME/.gnupg"
    mkBackupList "$HOME/.android"
    mkBackupList "$XDG_CONFIG_HOME/shodan/api_key"

    mkBackupList "$HOME/.cddb"
    mkBackupList "$HOME/.dvdcss"
    mkBackupList "$XDG_CONFIG_HOME/aacs"
    mkBackupList "$XDG_CONFIG_HOME/adept"

    mkBackupList "$XDG_CONFIG_HOME/opencode"
    mkBackupList "$XDG_DATA_HOME/opencode"
    mkBackupList "$XDG_STATE_HOME/opencode"

    mkBackupList "$HOME/.brv"
    mkBackupList "$HOME/exedev.crontab"
    mkBackupList "$HOME/grimoire"
    mkBackupList "$HOME/.hermes"
    mkBackupList "$HOME/inaba"
    mkBackupList "$HOME/journal"
    mkBackupList "$HOME/research"
    mkBackupList "$XDG_CONFIG_HOME/brv"
    mkBackupList "$XDG_CONFIG_HOME/obsidian-headless"
    mkBackupList "$XDG_DATA_HOME/tirith"
    mkBackupList "$XDG_STATE_HOME/brv"
    mkBackupList "$XDG_STATE_HOME/hermes"
    mkBackupList "$XDG_STATE_HOME/tirith"
    find "$HOME" -mindepth 1 -maxdepth 1 -type f -name 'hermes-backup-*.zip' >> "$BACKUP_LIST"

    mkBackupList "$HOME/.bash_history"
    mkBackupList "$HOME/.zsh_history"
    mkBackupList "$XDG_CONFIG_HOME/zsh/.zsh_history"
    mkBackupList "$XDG_DATA_HOME/fish/fish_history"

    mkBackupList "$HOME/Library/Application Support/obsidian"
    mkBackupList "$HOME/Library/Application Support/BraveSoftware"

    mkBackupList "$HOME/Projects"
    mkBackupList "$HOME/src"

    grep "^$HOME/" "$BACKUP_LIST" | sed "s#^$HOME/##g" | sort -u > "$BACKUP_LIST_TMP"
    mv "$BACKUP_LIST_TMP" "$BACKUP_LIST"

    (
      cd "$HOME"
      echo ""
      echo "=== Creating backup archive ==="
      echo ""
      if [[ -d "$HOME/Downloads" ]]; then
        BACKUP_DIR="$HOME/Downloads"
      elif [[ -d /mnt/share/Download ]]; then
        BACKUP_DIR=/mnt/share/Download
      else
        BACKUP_DIR="$HOME"
      fi
      tar -cJv -f "$BACKUP_DIR/backup.tar.xz" -T "$BACKUP_LIST"
    )

    rm -f "$BACKUP_LIST"
  '';
}
