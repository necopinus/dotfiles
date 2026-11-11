{
  writeShellApplication,
  coreutils,
  curl,
  ephemeral-git,
  findutils,
  gpth-neo,
  jq,
  openssl,
  rclone,
  yt-dlp,
}:
writeShellApplication {
  name = "vault-sync";

  runtimeInputs = [
    coreutils
    curl
    ephemeral-git
    findutils
    gpth-neo
    jq
    openssl
    rclone
    yt-dlp
  ];

  text = ''
    # Fail before using a missing or relative path in a destructive operation.
    function requireAbsolutePath {
      if [[ -z "$2" || "$2" != /* ]]; then
        printf '%s must be set to a non-empty absolute path\n' "$1" >&2
        exit 1
      fi
    }
    requireAbsolutePath HOME "''${HOME:-}"
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_CONFIG_HOME
    requireAbsolutePath XDG_CONFIG_HOME "$XDG_CONFIG_HOME"

    # Git helper functions
    function gitWithoutHooks {
      ephemeral-git -c core.hooksPath=/dev/null "$@"
    }

    # Match ssh:// URLs and scp-style user@host:path remotes. Other remote
    # types are read-only for this backup.
    function isSshRemote {
      [[ "$1" =~ ^ssh:// ]] || [[ "$1" =~ ^[^/]+@[^/]+:.+ ]]
    }

    # Re-exec using ephemeral-git to prevent having to repeatedly set up
    # a pass-cli session
    if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
      exec ephemeral-git --batch "$0" "$@"
    fi

    # Convenience variables
    PRIMARY_VAULT="/Volumes/Vault"
    SECONDARY_VAULT="/Volumes/Vault 1"
    DROPBOX_DIR="$HOME/Cardboard Iguana Dropbox"
    BEARER_FILE="$HOME/Downloads/journey.bearer"
    RCLONE_CONFIG_DIR="$XDG_CONFIG_HOME/rclone"
    RCLONE_EXCLUDE="$RCLONE_CONFIG_DIR/exclude"
    RCLONE_VAULT_SYNC_EXCLUDE="$RCLONE_CONFIG_DIR/vault-sync.exclude"

    # Temporary paths are registered as soon as they are created. If a Journey
    # update is interrupted during its directory swap, restore the old entry.
    TEMP_PATHS=()
    JOURNAL_SWAP_FINAL=""
    JOURNAL_SWAP_BACKUP=""
    function cleanupOnExit {
      local exit_status=$?
      local temp_path

      if [[ -n "$JOURNAL_SWAP_FINAL" && -n "$JOURNAL_SWAP_BACKUP" ]] &&
         [[ ! -e "$JOURNAL_SWAP_FINAL" && ! -L "$JOURNAL_SWAP_FINAL" ]] &&
         [[ -e "$JOURNAL_SWAP_BACKUP" || -L "$JOURNAL_SWAP_BACKUP" ]]; then
        if ! mv -- "$JOURNAL_SWAP_BACKUP" "$JOURNAL_SWAP_FINAL"; then
          echo "Unable to restore $JOURNAL_SWAP_FINAL from $JOURNAL_SWAP_BACKUP" >&2
          exit_status=1
        fi
      fi

      for temp_path in "''${TEMP_PATHS[@]}"; do
        if ! rm -rf -- "$temp_path"; then
          echo "Unable to remove temporary path: $temp_path" >&2
          exit_status=1
        fi
      done

      # The Chrome bearer token is sensitive and is single-use for this script.
      if ! rm -f -- "$BEARER_FILE"; then
        echo "Unable to remove Journey bearer token: $BEARER_FILE" >&2
        exit_status=1
      fi

      # exit, rather than return, propagates cleanup failures from an EXIT trap.
      exit "$exit_status"
    }
    trap cleanupOnExit EXIT

    # Mirror only non-empty sources. Checking through rclone makes this guard
    # use the same exclusions as the sync, including macOS system folders.
    function syncDirectory {
      local source="$1"
      local destination="$2"
      shift 2

      local first_entry
      if ! first_entry="$(
        rclone lsf --exclude-from "$RCLONE_EXCLUDE" \
             --exclude-from "$RCLONE_VAULT_SYNC_EXCLUDE" \
             --max-depth 1 "$source"/
      )"; then
        echo "Unable to inspect sync source: $source" >&2
        return 1
      fi
      if [[ -z "$first_entry" ]]; then
        echo "Sync source is empty after exclusions: $source" >&2
        return 1
      fi

      mkdir -p "$destination"
      rclone sync --progress --verbose \
           --check-first \
           --create-empty-src-dirs \
           --delete-after \
           --exclude-from "$RCLONE_EXCLUDE" \
           --exclude-from "$RCLONE_VAULT_SYNC_EXCLUDE" \
           --modify-window 1s \
           "$@" \
           "$source"/ \
           "$destination"/
    }

    # Download and verify a changed Journey entry in a staging directory. The
    # previous entry remains intact until every replacement file is ready.
    function backupJournal {
      local json_root="$1"
      local journal="$2"
      local journal_id="$3"
      local final_dir="$json_root/$journal_id"
      local staging_dir
      local backup_dir=""

      if ! jq -e '
        (.id | type == "string") and
        (.version != null) and
        (((.tags // []) | type) == "array") and
        (((.files // []) | type) == "array")
      ' > /dev/null <<< "$journal"; then
        echo "Invalid Journey payload for $journal_id" >&2
        return 1
      fi

      staging_dir="$(mktemp -d "$json_root/.vault-sync.$journal_id.XXXXXX")"
      TEMP_PATHS+=("$staging_dir")

      echo "$journal_id > $journal_id.json"
      jq '{
        id: .id,
        activity: .activity,
        address: .address,
        dateOfJournal: .dateOfJournal,
        encrypted: .encrypted,
        favourite: .favourite,
        location: .location,
        music: .music,
        sentiment: .sentiment,
        type: .type,
        timezone: .timezone,
        updatedAt: .updatedAt,
        version: .version,
        weather: .weather,
        tags: [ (.tags // [])[].name ],
        text: .text,
        schemaVersion: 2
      }' <<< "$journal" > "$staging_dir/$journal_id.json"

      local file
      while IFS= read -r file; do
        local attachment_id
        local extension
        local download_url
        local expected_md5
        attachment_id="$(jq -r '.id // empty' <<< "$file")"
        extension="$(jq -r '.variants.original.ext // empty' <<< "$file")"
        download_url="$(jq -r '.variants.original.path // empty' <<< "$file")"
        expected_md5="$(jq -r '.variants.original.md5 // empty' <<< "$file")"

        # These values become local paths or URLs. Reject malformed API data
        # instead of allowing path traversal or an unexpected curl protocol.
        if [[ ! "$attachment_id" =~ ^[A-Za-z0-9_-]+$ ]] ||
           [[ ! "$extension" =~ ^\.[A-Za-z0-9]{1,10}$ ]] ||
           [[ "$download_url" != https://* ]] || [[ -z "$expected_md5" ]]; then
          echo "Invalid attachment metadata for Journey entry $journal_id" >&2
          return 1
        fi

        local attachment="$attachment_id$extension"
        echo "                     > $attachment"
        curl --fail --silent --show-error --location \
             --connect-timeout 30 \
             --speed-limit 1024 --speed-time 120 \
             --retry 3 --retry-delay 2 --retry-all-errors \
             --proto '=https' --proto-redir '=https' \
             --output "$staging_dir/$attachment" \
             "$download_url"

        local actual_md5
        actual_md5="$(openssl dgst -md5 -binary < "$staging_dir/$attachment" | openssl enc -base64 -A)"
        if [[ "$expected_md5" != "$actual_md5" ]]; then
          echo "Mismatched MD5 sum for $attachment; keeping the previous Journey entry" >&2
          return 1
        fi
      done < <(jq -rc '(.files // [])[]' <<< "$journal")

      # Rename the old entry aside before installing the staged entry. The EXIT
      # trap reverses the first rename if the second one cannot complete.
      if [[ -e "$final_dir" || -L "$final_dir" ]]; then
        backup_dir="$(mktemp -d "$json_root/.vault-sync.old.$journal_id.XXXXXX")"
        rmdir "$backup_dir"
        JOURNAL_SWAP_FINAL="$final_dir"
        JOURNAL_SWAP_BACKUP="$backup_dir"
        mv -- "$final_dir" "$backup_dir"
      fi

      if ! mv -- "$staging_dir" "$final_dir"; then
        if [[ -n "$backup_dir" ]]; then
          mv -- "$backup_dir" "$final_dir"
          JOURNAL_SWAP_FINAL=""
          JOURNAL_SWAP_BACKUP=""
        fi
        return 1
      fi

      JOURNAL_SWAP_FINAL=""
      JOURNAL_SWAP_BACKUP=""
      if [[ -n "$backup_dir" ]]; then
        rm -rf -- "$backup_dir"
      fi
    }

    # Make sure that rclone is set up
    mkdir -p "$RCLONE_CONFIG_DIR"
    if [[ ! -f "$RCLONE_EXCLUDE" ]]; then
      cat > "$RCLONE_EXCLUDE" <<- EOF
    	# Files
    	*~
    	*.swp
    	._*
    	.#*
    	.com.apple.timemachine.supported
    	.DS_Store
    	.localized
    	.metadata
    	Thumbs.db

    	# Folders
    	.stfolder/
    	.stversions/
    	.fseventsd/
    	.recycle/
    	.Spotlight-V100/
    	.thumbnails/
    	.trash/
    	.Trash/
    	.Trashes/
    	.xvpics/
    	LOST.DIR/

    	# Android folders
    	/Android/
    	/NVIDIA_SHIELD/
    	EOF
    fi

    # Keep script-managed exclusions separate so upgrades add new rules without
    # overwriting any user changes to the original exclude file.
    RCLONE_EXCLUDE_TEMP="$(mktemp "$RCLONE_CONFIG_DIR/vault-sync.exclude.XXXXXX")"
    TEMP_PATHS+=("$RCLONE_EXCLUDE_TEMP")
    printf '%s\n' '*.part' '*.ytdl' '.vault-sync.*/' > "$RCLONE_EXCLUDE_TEMP"
    mv -- "$RCLONE_EXCLUDE_TEMP" "$RCLONE_VAULT_SYNC_EXCLUDE"

    if [[ ! -f "$RCLONE_CONFIG_DIR/rclone.conf" ]]; then
      touch "$RCLONE_CONFIG_DIR/rclone.conf"
    fi

    # Sync process
    if [[ -d "$PRIMARY_VAULT" ]] && [[ ! -d "$SECONDARY_VAULT" ]]; then
      # Run the Journey backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Journey" ]]; then
        if [[ ! -f "$BEARER_FILE" ]] || [[ -L "$BEARER_FILE" ]]; then
          echo "Journey bearer token not found in ~/Downloads/journey.bearer!" >&2
          exit 1
        fi

        chmod 600 "$BEARER_FILE"
        BEARER_TOKEN="$(< "$BEARER_FILE")"
        if [[ -z "$BEARER_TOKEN" ]] || [[ "$BEARER_TOKEN" == *$'\n'* ]] ||
           [[ "$BEARER_TOKEN" == *$'\r'* ]]; then
          echo "Journey bearer token must be a non-empty, single-line value" >&2
          exit 1
        fi

        JOURNEY_JSON_ROOT="$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON"
        mkdir -p "$JOURNEY_JSON_ROOT"
        SYNC_DRIVE_ID="aaq0YvdAs5NoWORX3R9z"
        LAST_ID="--------"

        while [[ "$LAST_ID" != "" ]] && [[ "$LAST_ID" != "null" ]]; do
          if [[ "$LAST_ID" == "--------" ]]; then
            LAST_ID=""
          fi

          REQUEST_BODY="$(jq -n \
            --arg syncDriveId "$SYNC_DRIVE_ID" \
            --arg lastId "$LAST_ID" \
            '{
              syncDriveId: $syncDriveId,
              lastId: $lastId,
              fields: [
                "activity",
                "address",
                "favourite",
                "location",
                "music",
                "sentiment",
                "type",
                "timezone",
                "updatedAt",
                "version",
                "weather",
                "tags",
                "text",
                "files.variants.original"
              ],
              sortBy: "dateOfJournal",
              order: "desc"
            }')"

          # Read the Authorization header through a file descriptor so the
          # bearer token does not appear in curl's process arguments.
          JOURNAL_BATCH="$(
            printf '%s' "$REQUEST_BODY" |
              curl --fail --silent --show-error \
                   --request POST \
                   --header @<(printf 'Authorization: %s\n' "$BEARER_TOKEN") \
                   --header 'Content-Type: application/json' \
                   --connect-timeout 30 --max-time 120 \
                   --retry 3 --retry-delay 2 --retry-all-errors \
                   --proto '=https' --proto-redir '=https' \
                   --data-binary @- \
                   https://sync.journey.cloud/v1/entries/list
          )"

          if ! jq -e '
            ((.data | type) == "array") and
            (.lastId == null or (.lastId | type) == "string")
          ' > /dev/null <<< "$JOURNAL_BATCH"; then
            echo "Journey API returned an invalid response" >&2
            exit 1
          fi

          while IFS= read -r JOURNAL; do
            JOURNAL_ID="$(jq -r '.id // empty' <<< "$JOURNAL")"
            JOURNAL_VERSION="$(jq -r '.version // empty' <<< "$JOURNAL")"
            if [[ ! "$JOURNAL_ID" =~ ^[A-Za-z0-9_-]+$ ]] || [[ -z "$JOURNAL_VERSION" ]]; then
              echo "Journey API returned an invalid entry ID or version" >&2
              exit 1
            fi

            JOURNAL_DIR="$JOURNEY_JSON_ROOT/$JOURNAL_ID"
            OLD_JOURNAL_VERSION=""
            if [[ -f "$JOURNAL_DIR/$JOURNAL_ID.json" ]]; then
              # A damaged old file needs a fresh download, not deletion before
              # the replacement has passed its attachment checks.
              if ! OLD_JOURNAL_VERSION="$(jq -r '.version // empty' "$JOURNAL_DIR/$JOURNAL_ID.json")"; then
                OLD_JOURNAL_VERSION=""
              fi
            fi

            if [[ -d "$JOURNAL_DIR" ]] && [[ "$OLD_JOURNAL_VERSION" == "$JOURNAL_VERSION" ]]; then
              echo "$JOURNAL_ID already exists..."
            else
              backupJournal "$JOURNEY_JSON_ROOT" "$JOURNAL" "$JOURNAL_ID"
            fi
          done < <(jq -rc '.data[]' <<< "$JOURNAL_BATCH")

          NEXT_LAST_ID="$(jq -r '.lastId // empty' <<< "$JOURNAL_BATCH")"
          if [[ -n "$NEXT_LAST_ID" ]] && [[ "$NEXT_LAST_ID" == "$LAST_ID" ]]; then
            echo "Journey API repeated pagination cursor $LAST_ID" >&2
            exit 1
          fi
          LAST_ID="$NEXT_LAST_ID"
        done

        unset BEARER_TOKEN
        rm -f -- "$BEARER_FILE"
      fi

      # Run the Yak Collective YouTube backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Google/Yak Collective (YouTube Channel)" ]]; then
        (
          cd "$DROPBOX_DIR/Nathan Acks/Archives/Google/Yak Collective (YouTube Channel)" || exit 1

          # Continue past unavailable videos and channel-level yt-dlp errors,
          # but make global failures visible in the backup output.
          set +e
          for YOUTUBE_URL in \
            "https://www.youtube.com/@yakcollective/featured" \
            "https://www.youtube.com/@yakcollective/videos" \
            "https://www.youtube.com/@yakcollective/shorts" \
            "https://www.youtube.com/@yakcollective/streams"
          do
            yt-dlp --output "%(upload_date)s %(title)s (%(id)s).%(ext)s" \
                   --format "bestvideo+bestaudio" \
                   --add-metadata \
                   --download-archive "Yak Collective Download History.txt" \
                   --write-subs \
                   --sub-format "json3/srt/best" \
                   --sub-langs en \
                   --write-auto-subs \
                   --ignore-errors \
                   --verbose \
                   "$YOUTUBE_URL"
            YT_DLP_STATUS=$?
            if [[ "$YT_DLP_STATUS" -ne 0 ]]; then
              echo "yt-dlp failed for $YOUTUBE_URL (status $YT_DLP_STATUS); continuing" >&2
            fi
          done
          exit 0
        )
      fi

      # Update the Google Photos backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Google/Personal/Google Photos" ]]; then
        GOOGLE_PHOTOS_TAKEOUT_DIR="$DROPBOX_DIR/Nathan Acks/Archives/Google/Personal/Google Photos"
        GOOGLE_PHOTOS_FINAL_DIR="$DROPBOX_DIR/Nathan Acks/Media/Pictures/GooglePhotos"

        mkdir -p "$GOOGLE_PHOTOS_FINAL_DIR"

        TMP_INPUT_ROOT_DIR="$(mktemp -d)"
        TEMP_PATHS+=("$TMP_INPUT_ROOT_DIR")
        TMP_OUTPUT_ROOT_DIR="$(mktemp -d)"
        TEMP_PATHS+=("$TMP_OUTPUT_ROOT_DIR")

        INPUT_DIR="$TMP_INPUT_ROOT_DIR/GooglePhotos"
        OUTPUT_DIR="$TMP_OUTPUT_ROOT_DIR/GooglePhotos"

        cp -a "$GOOGLE_PHOTOS_TAKEOUT_DIR" "$INPUT_DIR"

        if [[ -d "$INPUT_DIR/Trash" ]]; then
          rm -rf "$INPUT_DIR/Trash"
        fi

        gpth-neo --input "$INPUT_DIR" --output "$OUTPUT_DIR" --albums duplicate-copy --divide-partner-shared

        # Checksums are deliberate: processed Takeout timestamps are not
        # reliable enough for a size-and-mtime-only comparison.
        syncDirectory "$OUTPUT_DIR" "$GOOGLE_PHOTOS_FINAL_DIR" --checksum

        rm -rf -- "$TMP_INPUT_ROOT_DIR" "$TMP_OUTPUT_ROOT_DIR"
      fi

      # Sync Dropbox
      if [[ -d "$DROPBOX_DIR" ]]; then
        syncDirectory "$DROPBOX_DIR" "$PRIMARY_VAULT/Dropbox"
      fi

      # Sync Lightroom
      if [[ -d "$HOME/Pictures/Lightroom Library.lrlibrary" ]]; then
        syncDirectory "$HOME/Pictures/Lightroom Library.lrlibrary" "$PRIMARY_VAULT/Archives/Lightroom Library.lrlibrary"
      fi

      # Update GitHub repos
      for REPO_ROOT in "$HOME/Projects" "$HOME/src"; do
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

      # Preserve the existing destination layout: Projects takes precedence
      # when both repository roots exist.
      if [[ -d "$HOME/Projects" ]]; then
        syncDirectory "$HOME/Projects" "$PRIMARY_VAULT/src"
      elif [[ -d "$HOME/src" ]]; then
        syncDirectory "$HOME/src" "$PRIMARY_VAULT/src"
      fi

      # Remove .DS_Store and ._* files
      echo "Removing macOS graffiti..."
      find "$PRIMARY_VAULT" \( -iname ".DS_Store" -o -iname "._*" \) -delete
    elif [[ -d "$PRIMARY_VAULT" ]] && [[ -d "$SECONDARY_VAULT" ]]; then
      # Sync primary vault to secondary vault
      syncDirectory "$PRIMARY_VAULT" "$SECONDARY_VAULT"

      # Remove .DS_Store and ._* files
      echo "Removing macOS graffiti..."
      find "$SECONDARY_VAULT" \( -iname ".DS_Store" -o -iname "._*" \) -delete
    else
      echo "Primary vault does not appear to be mounted!" >&2
      exit 1
    fi

    # Mark script finish; this makes it easier to tell when an error has
    # occurred
    #
    echo "~*~ Update Complete ~*~"
  '';
}
