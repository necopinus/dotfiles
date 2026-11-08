{
  writeShellApplication,
  rclone,
}:
writeShellApplication {
  name = "vault-sync";

  runtimeInputs = [
    rclone
  ];

  text = ''
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
    	EOF
    fi
    if [[ ! -f "$XDG_CONFIG_HOME"/rclone/rclone.conf ]]; then
      touch "$XDG_CONFIG_HOME"/rclone/rclone.conf
    fi

    if [[ -d /Volumes/Vault ]] && [[ -d /Volumes/"Vault 1" ]]; then
      # An empty source is never a valid sync input. Stop before rclone can
      # delete the destination's existing contents.
      #
      if [[ -z "$(find /Volumes/Vault/ -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
        echo "Source vault is empty; refusing to sync." >&2
        exit 1
      fi
      rclone sync -Pv \
           --check-first \
           --create-empty-src-dirs \
           --delete-before \
           --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
           --fast-list \
           --modify-window 1s \
             /Volumes/Vault/ /Volumes/"Vault 1"/
    fi
  '';
}
