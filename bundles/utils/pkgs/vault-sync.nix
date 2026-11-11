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
  rsync,
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
    rsync
    yt-dlp
  ];

  text = ''
    # Git helper functions
    function gitWithoutHooks {
      ephemeral-git -c core.hooksPath=/dev/null "$@"
    }
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

    # Make sure that rclone is set up
    if [[ ! -d "$XDG_CONFIG_HOME"/rclone ]]; then
      mkdir -p "$XDG_CONFIG_HOME"/rclone
    fi
    if [[ ! -f "$XDG_CONFIG_HOME"/rclone/exclude ]]; then
      cat > "$XDG_CONFIG_HOME"/rclone/exclude <<- EOF
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
    if [[ ! -f "$XDG_CONFIG_HOME"/rclone/rclone.conf ]]; then
      touch "$XDG_CONFIG_HOME"/rclone/rclone.conf
    fi

    # Sync process
    if [[ -d "$PRIMARY_VAULT" ]] && [[ ! -d "$SECONDARY_VAULT" ]]; then
      # Run the Journey backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Journey" ]]; then
        if [[ ! -f "$HOME/Downloads/journey.bearer" ]]; then
          echo "Journey bearer token not found in ~/Downloads/journey.bearer!" >&2
          exit 1
        fi

        BEARER_TOKEN="$(cat "$HOME/Downloads/journey.bearer")"
        SYNC_DRIVE_ID="aaq0YvdAs5NoWORX3R9z"
        LAST_ID="--------"

        while [[ "$LAST_ID" != "" ]] && [[ "$LAST_ID" != "null" ]]; do
          if [[ "$LAST_ID" == "--------" ]]; then
            LAST_ID=""
          fi

          JOURNAL_BATCH="$(
            curl -s -X POST \
                 -H "Authorization: $BEARER_TOKEN" \
                 -H "Content-Type: application/json" \
                 -d '{
                       "syncDriveId": "'"$SYNC_DRIVE_ID"'",
                       "lastId": "'"$LAST_ID"'",
                       "fields": [
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
                       "sortBy": "dateOfJournal",
                       "order":"desc"
                     }' \
                  https://sync.journey.cloud/v1/entries/list
          )"

          while IFS= read -r JOURNAL; do
            JOURNAL_ID="$(echo "$JOURNAL" | jq -r .id)"
            JOURNAL_VERSION="$(echo "$JOURNAL" | jq -r .version)"

            OLD_JOURNAL_VERSION="null"
            if [[ -f "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID/$JOURNAL_ID.json" ]]; then
              OLD_JOURNAL_VERSION="$(cat "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID/$JOURNAL_ID.json" | jq -r .version)"
            fi

            if [[ "$OLD_JOURNAL_VERSION" != "$JOURNAL_VERSION" ]] || [[ "$OLD_JOURNAL_VERSION" == "null" ]]; then
              if [[ -e "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID" ]]; then
                rm -rf "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID"
              fi
            fi

            if [[ ! -d "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID" ]]; then
              echo "$JOURNAL_ID > $JOURNAL_ID.json"

              mkdir -p "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID"

              echo "$JOURNAL" | jq ". | { id: .id, activity: .activity, address: .address, dateOfJournal: .dateOfJournal, encrypted: .encrypted, favourite: .favourite, location: .location, music: .music, sentiment: .sentiment, type: .type, timezone: .timezone, updatedAt: .updatedAt, version: .version, weather: .weather, tags: [ .tags[].name ], text: .text, schemaVersion: 2 }" > "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID/$JOURNAL_ID.json"

              while IFS= read -r FILE; do
                ATTACHMENT="$(echo "$FILE" | jq -r .id)$(echo "$FILE" | jq -r ".variants.original.ext")"
                echo "                     > $ATTACHMENT"

                curl -s -o "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID/$ATTACHMENT" "$(echo "$FILE" | jq -r ".variants.original.path")"

                GOOD_MD5="$(echo "$FILE" | jq -r ".variants.original.md5")"
                ACTUAL_MD5="$(cat "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID/$ATTACHMENT" | openssl dgst -md5 -binary | openssl enc -base64)"

                if [[ "$GOOD_MD5" != "$ACTUAL_MD5" ]]; then
                  rm -rf "$DROPBOX_DIR/Nathan Acks/Archives/Journey/JSON/$JOURNAL_ID"
                  echo "Mismatched attachment MD5 sum! Aborting..." >&2
                  exit 1
                fi
              done < <(echo "$JOURNAL" | jq -rc ".files[]")
            else
              echo "$JOURNAL_ID already exists..."
            fi
          done < <(echo "$JOURNAL_BATCH" | jq -rc ".data[]")

          LAST_ID="$(echo "$JOURNAL_BATCH" | jq -r .lastId)"
        done

        rm "$HOME/Downloads/journey.bearer"
      fi

      # Run the Yak Collective YouTube backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Google/Yak Collective (YouTube Channel)" ]]; then
        (
          cd "$DROPBOX_DIR/Nathan Acks/Archives/Google/Yak Collective (YouTube Channel)"

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
                  "https://www.youtube.com/@yakcollective/featured" || true

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
                  "https://www.youtube.com/@yakcollective/videos" || true

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
                  "https://www.youtube.com/@yakcollective/shorts" || true

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
                  "https://www.youtube.com/@yakcollective/streams" || true
        )
      fi

      # Update the Google Photos backup
      if [[ -d "$DROPBOX_DIR/Nathan Acks/Archives/Google/Personal/Google Photos" ]]; then
        GOOGLE_PHOTOS_TAKEOUT_DIR="$DROPBOX_DIR/Nathan Acks/Archives/Google/Personal/Google Photos"
        GOOGLE_PHOTOS_FINAL_DIR="$DROPBOX_DIR/Nathan Acks/Media/Pictures/GooglePhotos"

        mkdir -p "$GOOGLE_PHOTOS_FINAL_DIR"

        TMP_INPUT_ROOT_DIR="$(mktemp -d)"
        TMP_OUTPUT_ROOT_DIR="$(mktemp -d)"

        INPUT_DIR="$TMP_INPUT_ROOT_DIR/GooglePhotos"
        OUTPUT_DIR="$TMP_OUTPUT_ROOT_DIR/GooglePhotos"

        cp -a "$GOOGLE_PHOTOS_TAKEOUT_DIR" "$INPUT_DIR"

        if [[ -d "$INPUT_DIR/Trash" ]]; then
          rm -rf "$INPUT_DIR/Trash"
        fi

        gpth-neo --input "$INPUT_DIR" --output "$OUTPUT_DIR" --albums duplicate-copy --divide-partner-shared

        rsync --checksum --recursive --no-xattrs --delete --force --progress "$OUTPUT_DIR"/ "$GOOGLE_PHOTOS_FINAL_DIR"/

        rm -rf "$TMP_INPUT_ROOT_DIR" "$TMP_OUTPUT_ROOT_DIR"
      fi

      # Sync Dropbox
      if [[ -d "$DROPBOX_DIR" ]]; then
        mkdir -p "$PRIMARY_VAULT/Dropbox"
        rclone sync -Pv \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
              "$DROPBOX_DIR"/ \
              "$PRIMARY_VAULT/Dropbox"/
      fi

      # Sync Lightroom
      if [[ -d "$HOME/Pictures/Lightroom Library.lrlibrary" ]]; then
        mkdir -p "$PRIMARY_VAULT/Archives/Lightroom Library.lrlibrary"
        rclone sync -Pv \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
              "$HOME/Pictures/Lightroom Library.lrlibrary"/ \
              "$PRIMARY_VAULT/Archives/Lightroom Library.lrlibrary"/
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

      # Sync GitHub repos
      if [[ -d "$HOME/Projects" ]] || [[ -d "$HOME/src" ]]; then
        mkdir -p "$PRIMARY_VAULT/src"
      fi
      if [[ -d "$HOME/Projects" ]]; then
        rclone sync -Pv \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
              "$HOME/Projects"/ \
              "$PRIMARY_VAULT/src"/
      elif [[ -d "$HOME/src" ]]; then
        rclone sync -Pv \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
              "$HOME/Projects"/ \
              "$PRIMARY_VAULT/src"/
      fi

      # Remove .DS_Store and ._* files
      echo "Removing macOS graffiti..."
      find "$PRIMARY_VAULT" \( -iname ".DS_Store" -o -iname "._*" \) -delete 2> /dev/null
    elif [[ -d "$PRIMARY_VAULT" ]] && [[ -d "$SECONDARY_VAULT" ]]; then
      # An empty source is never a valid sync input. Stop before rclone can
      # delete the destination's existing contents.
      if [[ -z "$(find "$PRIMARY_VAULT" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
        echo "Primary vault is empty! Refusing to sync..." >&2
        exit 1
      fi

      # Sync primary vault to secondary vault
      rclone sync -Pv \
           --check-first \
           --create-empty-src-dirs \
           --delete-before \
           --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
           --fast-list \
           --modify-window 1s \
            "$PRIMARY_VAULT"/ \
            "$SECONDARY_VAULT"/

      # Remove .DS_Store and ._* files
      echo "Removing macOS graffiti..."
      find "$SECONDARY_VAULT" \( -iname ".DS_Store" -o -iname "._*" \) -delete 2> /dev/null
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
