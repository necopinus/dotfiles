{writeShellApplication}:
writeShellApplication {
  name = "update-system";

  text = ''
    # Set OS type
    #
    OS="$(uname -s)"

    # Debian system packages
    #
    if [[ "$OS" == "Linux" ]]; then
      sudo apt update
      sudo apt full-upgrade
      sudo apt autoremove --purge --autoremove
      sudo apt clean
    fi

    # Clear out macOS settings that need to be set (or not set) explicitly
    #
    if [[ "$OS" == "Darwin" ]]; then
      defaults delete com.apple.TextEdit AlwaysLightBackground 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleAccentColor 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleHighlightColor 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleIconAppearanceTintColor 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleInterfaceStyle 2>/dev/null || true
    fi

    # Update Nix packages
    #
    sudo determinate-nixd upgrade
    (
      cd "$HOME/config/nix"
      nix flake update
      nix flake archive
      git add -A -v
      git commit -m "Automated system update: $(date)" || true
      git push
      if [[ "$OS" == "Darwin" ]]; then
        sudo darwin-rebuild switch --flake .#macos
      else
        home-manager switch --flake .#android
        sudo "$(which non-nixos-gpu-setup)"
      fi
    )
    sudo find /nix/var/nix/gcroots -xtype l -exec rm "{}" \;
    nix atore gc --verbose

    # Update Helix grammars
    #
    hx -g fetch
    hx -g build

    # Git repositories
    #
    if [[ -d "$HOME/src" ]]; then
      (
        cd "$HOME/src"
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

    # macOS system
    #
    # We do this last as this command may force a reboot
    #
    if [[ "$OS" == "Darwin" ]]; then
      softwareupdate --install --all --include-config --include-config-data
    fi
  '';
}
