{
  writeShellApplication,
  rclone,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "vault-sync";

  runtimeInputs = [
    rclone
    uutils-coreutils-noprefix
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
      if [[ -d /Volumes/"Vault 1"/Android ]] && [[ -d /Volumes/"Vault 1"/NVIDIA_SHIELD ]]; then
        rclone sync \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
             --progress \
             --verbose \
               /Volumes/"Vault 1"/Android/ /Volumes/Vault/Android/

        rclone sync \
             --check-first \
             --create-empty-src-dirs \
             --delete-before \
             --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
             --fast-list \
             --modify-window 1s \
             --progress \
             --verbose \
               /Volumes/"Vault 1"/NVIDIA_SHIELD/ /Volumes/Vault/NVIDIA_SHIELD/
      fi
      rclone sync \
           --check-first \
           --create-empty-src-dirs \
           --delete-before \
           --exclude-from "$XDG_CONFIG_HOME"/rclone/exclude \
           --fast-list \
           --modify-window 1s \
           --progress \
           --verbose \
             /Volumes/Vault/ /Volumes/"Vault 1"/
    fi
  '';
}
