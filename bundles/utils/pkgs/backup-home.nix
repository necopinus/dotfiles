{
  writeShellApplication,
  ephemeral-git,
}:
writeShellApplication {
  name = "backup-home";

  runtimeInputs = [
    ephemeral-git
  ];

  text = ''
    # Fail before using a missing or relative path in a destructive operation.
    # PORTABLE_PAT is handled separately because it is optional on some hosts.
    #
    function requireAbsolutePath {
      if [[ -z "$2" || "$2" != /* ]]; then
        printf '%s must be set to a non-empty absolute path\n' "$1" >&2
        exit 1
      fi
    }
    requireAbsolutePath HOME "''${HOME:-}"
    requireAbsolutePath XDG_CONFIG_HOME "''${XDG_CONFIG_HOME:-}"
    requireAbsolutePath XDG_DATA_HOME "''${XDG_DATA_HOME:-}"
    requireAbsolutePath XDG_STATE_HOME "''${XDG_STATE_HOME:-}"

    # Start one temporary agent and load one key before creating temporary
    # files or performing system changes. Re-execution happens exactly once.
    if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
      exec ephemeral-git --batch "$0" "$@"
    fi

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
        \) -exec realpath "{}" + >> "$BACKUP_LIST"
      elif [[ -f "$1" ]]; then
        echo "Adding file:  $1 ..."
        realpath "$1" >> "$BACKUP_LIST"
      fi
    }

    # Track the service stop window so every exit path attempts a restart.
    # Explicit restarts still fail the script; exit cleanup is best-effort and
    # preserves the original status.
    #
    HERMES_SERVICES_STOPPED=0
    function restartHermesServices {
      if [[ "$HERMES_SERVICES_STOPPED" == 1 ]]; then
        sudo systemctl --user -M "''${USER}@" start hermes-dashboard.service
        sudo systemctl --user -M "''${USER}@" start hermes-gateway.service
        sudo systemctl --user -M "''${USER}@" start hermes-relay.service
        HERMES_SERVICES_STOPPED=0
      fi
    }
    function cleanupOnExit {
      local exit_status=$?
      restartHermesServices || true
      return "$exit_status"
    }
    trap cleanupOnExit EXIT

    # Automated updates and backups must never execute repository-controlled
    # hooks while credentials are available or a system update is in progress.
    #
    function gitWithoutHooks {
      ephemeral-git -c core.hooksPath=/dev/null "$@"
    }

    # Match ssh:// URLs and scp-style user@host:path remotes, with or
    # without a .git suffix. HTTP(S) and local paths do not match.
    #
    function isSshRemote {
      [[ "$1" =~ ^ssh:// ]] || [[ "$1" =~ ^[^/]+@[^/]+:.+ ]]
    }

    # Make sure repositories in the configured roots are up to date. Each
    # root is optional, and every child repository is refreshed without hooks.
    #
    for REPO_ROOT in "$HOME/Projects" "$HOME/src" "$HOME/workspace"; do
      if [[ -d "$REPO_ROOT" ]]; then
        (
          cd "$REPO_ROOT" || exit 1
          while IFS= read -r -d "" OBJECT; do
            if [[ -f "$OBJECT/.git/config" ]] && [[ $(grep -c "url = " "$OBJECT/.git/config") -gt 0 ]]; then
              echo "Refreshing $(basename "$OBJECT")"
              if ! cd "$OBJECT"; then
                echo "Unable to enter $OBJECT; skipping repository" >&2
                continue
              fi
              if ! gitWithoutHooks pull --ff-only --recurse-submodules; then
                echo "Pull failed for $OBJECT; skipping push" >&2
                cd ..
                continue
              fi
              if ! REMOTE_URL="$(gitWithoutHooks config --get remote.origin.url)"; then
                echo "Unable to read the remote for $OBJECT; skipping push" >&2
              elif isSshRemote "$REMOTE_URL"; then
                if ! gitWithoutHooks push --recurse-submodules=on-demand; then
                  echo "Push failed for $OBJECT; continuing backup" >&2
                fi
              fi
              cd ..
            fi
          done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
        )
      fi
    done

    # Actual backups
    #
    if [[ "$(hostname)" == "kitsune" ]]; then
      HERMES_SERVICES_STOPPED=1
      sudo systemctl --user -M "''${USER}@" stop hermes-relay.service
      sudo systemctl --user -M "''${USER}@" stop hermes-gateway.service
      sudo systemctl --user -M "''${USER}@" stop hermes-dashboard.service

      hermes backup

      # Preserve the previous crontab backup unless `crontab -l` succeeds.
      # Keep the temporary file on the same filesystem so the final rename is
      # atomic. A missing crontab is not an error, but other failures are.
      #
      CRONTAB_BACKUP_DIR="$(mktemp -d "$HOME/.exedev.crontab.XXXXXX")"
      if LC_ALL=C crontab -l > "$CRONTAB_BACKUP_DIR/crontab" 2> "$CRONTAB_BACKUP_DIR/error"; then
        mv "$CRONTAB_BACKUP_DIR/crontab" "$HOME/exedev.crontab"
      elif ! grep -q "no crontab for" "$CRONTAB_BACKUP_DIR/error"; then
        cat "$CRONTAB_BACKUP_DIR/error" >&2
        rm -rf "$CRONTAB_BACKUP_DIR"
        exit 1
      fi
      rm -rf "$CRONTAB_BACKUP_DIR"
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
    mkBackupList "$HOME/.hermes"
    mkBackupList "$HOME/inaba"
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

    mkBackupList "$HOME/Projects"
    mkBackupList "$HOME/src"

    # Strip the home directory as a literal prefix, not as a regular
    # expression. Paths outside the home directory remain excluded.
    #
    home_prefix="''${HOME%/}/"
    while IFS= read -r path; do
      if [[ "$path" == "$home_prefix"* ]]; then
        printf '%s\n' "''${path#"$home_prefix"}"
      fi
    done < "$BACKUP_LIST" | sort -u > "$BACKUP_LIST_TMP"
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

    restartHermesServices
  '';
}
