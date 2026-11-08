{writeShellApplication}:
writeShellApplication {
  name = "backup-home";

  # Remove "nounset" from the options default list, as PORTABLE_PAT may
  # be unset
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

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

    # Load the portable SSH key into the environment using an ephemeral Proton Pass session
    #
    if [[ -n "$PORTABLE_PAT" ]]; then
      PORTABLE_DIR="$(mktemp -d)"
      env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli login
      PORTABLE_SSH_KEY="$(env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
      env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli ssh-agent load --vault-name Portable
      env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli logout
      rm -rf "$PORTABLE_DIR"
    else
      if ! pass-cli info &> /dev/null; then
        pass-cli login
      fi
      PORTABLE_SSH_KEY="$(pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
      pass-cli ssh-agent load --vault-name Portable
    fi

    export PORTABLE_SSH_KEY
    export SSH_COMMAND="ssh -i /dev/null"

    # Make sure all git repos are up to date
    #
    if [[ -d "$HOME/Projects" ]]; then
      (
        cd "$HOME/Projects" || exit 1
        while IFS= read -r -d "" OBJECT; do
          if [[ -d "$OBJECT/.git" ]]; then
            echo "Refreshing $(basename "$OBJECT")"
            cd "$OBJECT"
            git pull --recurse-submodules
            if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
              git push --recurse-submodules=on-demand
            fi
            cd ..
          fi
        done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
      )
    fi
    if [[ -d "$HOME/src" ]]; then
      (
        cd "$HOME/src" || exit 1
        while IFS= read -r -d "" OBJECT; do
          if [[ -d "$OBJECT/.git" ]]; then
            echo "Refreshing $(basename "$OBJECT")"
            cd "$OBJECT"
            git pull --recurse-submodules
            if [[ "$(git config --get remote.origin.url)" =~ [^/]+@[^/]+\.[^/]+:.+\.git ]]; then
              git push --recurse-submodules=on-demand
            fi
            cd ..
          fi
        done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
      )
    fi
    if [[ -d "$HOME/grimoire" ]]; then
      (
        cd "$HOME/grimoire" || exit 1
        git pull
        git push
      )
    fi
    if [[ -d "$HOME/journal" ]]; then
      (
        cd "$HOME/journal" || exit 1
        git pull
        git push
      )
    fi
    if [[ -d "$HOME/research" ]]; then
      (
        cd "$HOME/research" || exit 1
        git pull
        git push
      )
    fi

    # Remove the portable SSH key from ssh-agent
    #
    echo "$PORTABLE_SSH_KEY" | ssh-add -d -
    unset PORTABLE_SSH_KEY SSH_COMMAND

    # Actual backups
    #
    if [[ "$(hostname)" == "kitsune" ]]; then
      sudo systemctl --user -M "''${USER}@" stop hermes-relay.service
      sudo systemctl --user -M "''${USER}@" stop hermes-gateway.service
      sudo systemctl --user -M "''${USER}@" stop hermes-dashboard.service

      hermes backup
      crontab -l > "$HOME/exedev.crontab"
    fi

    mkBackupList "$XDG_CONFIG_HOME/nix"

    mkBackupList "$HOME/.android"
    mkBackupList "$HOME/.git-credentials"
    mkBackupList "$HOME/.gnupg"
    mkBackupList "$HOME/.ssh"
    mkBackupList "$XDG_CONFIG_HOME/git"
    mkBackupList "$XDG_CONFIG_HOME/shodan/api_key"

    mkBackupList "$HOME/.cddb"
    mkBackupList "$HOME/.dvdcss"
    mkBackupList "$XDG_CONFIG_HOME/aacs"
    mkBackupList "$XDG_CONFIG_HOME/adept"

    mkBackupList "$XDG_CONFIG_HOME/opencode"
    mkBackupList "$XDG_DATA_HOME/opencode"
    mkBackupList "$XDG_STATE_HOME/opencode"

    mkBackupList "$HOME/exedev.crontab"
    mkBackupList "$HOME/grimoire"
    mkBackupList "$HOME/.hermes"
    mkBackupList "$HOME/inaba"
    mkBackupList "$HOME/journal"
    mkBackupList "$HOME/research"
    mkBackupList "$HOME/workspace"
    mkBackupList "$HOME/.xurl"
    mkBackupList "$XDG_DATA_HOME/tirith"
    mkBackupList "$XDG_STATE_HOME/hermes"
    mkBackupList "$XDG_STATE_HOME/tirith"
    find "$HOME" -mindepth 1 -maxdepth 1 -type f -name 'hermes-backup-*.zip' >> "$BACKUP_LIST"

    mkBackupList "$HOME/.bash_history"
    mkBackupList "$HOME/.zsh_history"
    mkBackupList "$XDG_CONFIG_HOME/zsh/.zsh_history"
    mkBackupList "$XDG_DATA_HOME/fish/fish_history"

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

    if [[ "$(hostname)" == "kitsune" ]]; then
      sudo systemctl --user -M "''${USER}@" start hermes-dashboard.service
      sudo systemctl --user -M "''${USER}@" start hermes-gateway.service
      sudo systemctl --user -M "''${USER}@" start hermes-relay.service
    fi
  '';
}
