{
  writeShellApplication,
  git,
  uutils-coreutils-noprefix,
  uutils-findutils,
}:
writeShellApplication {
  name = "update-system";

  runtimeInputs = [
    git
    uutils-coreutils-noprefix
    uutils-findutils
  ];

  text = ''
    # Set OS type
    #
    OS="$(uname -s)"

    # (Debian) Linux system packages
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
      defaults delete kCFPreferencesAnyApplication AppleAccentColor 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleHighlightColor 2>/dev/null || true
      defaults delete kCFPreferencesAnyApplication AppleIconAppearanceTintColor 2>/dev/null || true
    fi

    # Update Nix packages
    #
    sudo determinate-nixd upgrade
    if [[ "$OS" == "Darwin" ]] && [[ -d "$HOME"/.cache/nix/fetcher-locks ]]; then
      sudo chown "$USER":staff "$HOME"/.cache/nix/fetcher-locks/*
    fi
    (
      cd "$XDG_CONFIG_HOME"/nix
      mkdir -p "$XDG_CACHE_HOME"/nix/flakes
      cp flake.lock "$XDG_CACHE_HOME/nix/flakes/flake.$(date "+%Y%m%d%H%M%S").lock"
      git pull
      nix flake update
      nix flake archive
      git add -A -v
      git -c user.signingKey="''${GIT_SIGNING_KEY:-$HOME/.ssh/id_ed25519}" commit -m "Automated system update: $(date)" || true
      git push
      if [[ "$OS" == "Darwin" ]]; then
        sudo darwin-rebuild switch --flake .#macos
      elif [[ "$USER" == "droid" ]]; then
        home-manager switch --flake .#android
        sudo "$(which non-nixos-gpu-setup)"
      elif [[ "$USER" == "exedev" ]]; then
        home-manager switch --flake .#exedev
        sudo "$(which non-nixos-gpu-setup)"
      else
        home-manager switch --flake .#linux
        sudo "$(which non-nixos-gpu-setup)"
      fi
    )

    # Garbage collection
    #
    nix-collect-garbage --delete-older-than 14d
    sudo find /nix/var/nix/gcroots -xtype l -exec rm -v "{}" \;
    nix store gc -v
    nix store optimise -v
    echo ""

    # Git repositories
    #
    if [[ -d "$HOME/Projects" ]] || [[ -d "$HOME/src" ]]; then
      (
        if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$HOME/Projects" ]]; then
          cd "$HOME/Projects" || exit 1
        elif [[ "$(uname -s)" == "Linux" ]] && [[ -d "$HOME/src" ]]; then
          cd "$HOME/src" || exit 1
        else
          exit 1
        fi
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
      softwareupdate -ia --include-config --include-config-data
    fi
  '';
}
