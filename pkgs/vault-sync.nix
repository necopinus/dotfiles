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
    if [[ -z "$XDG_CONFIG_HOME" ]]; then
      export XDG_CONFIG_HOME="$HOME/.config"
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
