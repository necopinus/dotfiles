{
  writeShellApplication,
  ephemeralGit,
}:
writeShellApplication {
  name = "update-system";

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
    requireAbsolutePath XDG_CACHE_HOME "''${XDG_CACHE_HOME:-}"

    # Start one temporary agent and load one key before any system changes.
    # Re-execution happens before package updates so they run only once.
    if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
      exec ${ephemeralGit}/bin/ephemeral-git --batch "$0" "$@"
    fi

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
      ${ephemeralGit}/bin/ephemeral-git -c core.hooksPath=/dev/null "$@"
    }

    # Match ssh:// URLs and scp-style user@host:path remotes, with or
    # without a .git suffix. HTTP(S) and local paths do not match.
    #
    function isSshRemote {
      [[ "$1" =~ ^ssh:// ]] || [[ "$1" =~ ^[^/]+@[^/]+:.+ ]]
    }

    # Update Nix packages
    #
    sudo -H determinate-nixd upgrade
    if [[ "$OS" == "Darwin" ]] && [[ -d "$HOME"/.cache/nix ]]; then
      sudo chown -R "$USER":staff "$HOME"/.cache/nix
    fi
    (
      cd "$XDG_CONFIG_HOME"/nix
      mkdir -p "$XDG_CACHE_HOME"/nix/flakes
      cp flake.lock "$XDG_CACHE_HOME/nix/flakes/flake.$(date "+%Y%m%d%H%M%S").lock"
      gitWithoutHooks pull --ff-only
      nix flake update
      nix flake archive
      # Commit only the generated lockfile. Other work in the repository must
      # not become part of the automated update. Continue without a commit when
      # the flake update leaves the lockfile unchanged.
      #
      gitWithoutHooks add -v -- flake.lock
      if gitWithoutHooks diff --cached --quiet -- flake.lock; then
        echo "No flake.lock changes to commit"
      else
        gitWithoutHooks commit -m "Automated system update: $(date)" -- flake.lock
      fi
      gitWithoutHooks push
      if [[ "$OS" == "Darwin" ]]; then
        sudo -H darwin-rebuild switch --flake .#macos
      elif [[ "$(hostname)" == "kitsune" ]]; then
        home-manager switch --flake .#hermes
        sudo "$(command -v non-nixos-gpu-setup)"
      elif [[ "$USER" == "exedev" ]]; then
        home-manager switch --flake .#exedev
        sudo "$(command -v non-nixos-gpu-setup)"
      fi
    )
    if [[ "$OS" == "Darwin" ]] && [[ -d "$HOME"/.cache/nix ]]; then
      sudo chown -R "$USER":staff "$HOME"/.cache/nix
    fi

    # Clear local NPM cache (fixes library version mismatch issues after
    # an upgrade)
    #
    if [[ -d "$HOME/.npm" ]]; then
      rm -rf "$HOME/.npm"
    fi

    # Update OpenCode settings
    #
    if [[ -d "$XDG_CONFIG_HOME"/opencode ]]; then
      herdr integration install opencode
    fi

    # Update Hermes
    #
    if [[ "$(hostname)" == "kitsune" ]]; then
      HERMES_SERVICES_STOPPED=1
      sudo systemctl --user -M "''${USER}@" stop hermes-relay.service
      sudo systemctl --user -M "''${USER}@" stop hermes-gateway.service
      sudo systemctl --user -M "''${USER}@" stop hermes-dashboard.service

      hermes update --yes

      if [[ -d "$HOME/.hermes/mnemosyne-venv" ]]; then
        rm -rf "$HOME/.hermes/mnemosyne-venv"
      fi
      uv venv --python 3.14 "$HOME/.hermes/mnemosyne-venv"
      (
        cd "$HOME/.hermes/mnemosyne-venv"
        uv pip install --prerelease=explicit "mnemosyne-memory[embeddings]>=4.0.0b5" "mnemosyne-hermes"
        uv run mnemosyne-hermes --hermes-home "$HOME/.hermes" install --force --mode wrapper --python "$HOME/.hermes/mnemosyne-venv/bin/python"
      )

      curl -fsSL https://raw.githubusercontent.com/xdevplatform/xurl/main/install.sh | bash

      herdr integration install hermes

      if [[ -d "$XDG_CONFIG_HOME"/bash/rc.d ]]; then
        hermes completion bash > "$XDG_CONFIG_HOME"/bash/rc.d/hermes-completion.sh
      fi
      if [[ -d "$XDG_CONFIG_HOME"/zsh/rc.d ]]; then
        hermes completion zsh > "$XDG_CONFIG_HOME"/zsh/rc.d/hermes-completion.zsh
      fi
      if [[ -d "$XDG_CONFIG_HOME"/fish/completions ]]; then
        hermes completion fish > "$XDG_CONFIG_HOME"/fish/completions/hermes.fish
      fi

      hermes plugins install Codename-11/hermes-relay/plugin --enable --yes-deps --force

      restartHermesServices
    fi

    # Git repositories in the configured roots. Each root is optional, and
    # every immediate child repository is refreshed without running hooks.
    #
    for REPO_ROOT in "$HOME/Projects" "$HOME/src" "$HOME/workspace"; do
      if [[ -d "$REPO_ROOT" ]]; then
        (
          cd "$REPO_ROOT" || exit 1
          while IFS= read -r -d "" OBJECT; do
            if [[ -f "$OBJECT/.git/config" ]] && [[ $(grep -c "url = " "$OBJECT/.git/config") -gt 0 ]]; then
              echo "Refreshing $(basename "$OBJECT")"
              cd "$OBJECT"
              gitWithoutHooks pull --ff-only --recurse-submodules
              if REMOTE_URL="$(gitWithoutHooks config --get remote.origin.url)" && isSshRemote "$REMOTE_URL"; then
                gitWithoutHooks push --recurse-submodules=on-demand
              fi
              cd ..
            fi
          done < <(find . -mindepth 1 -maxdepth 1 -type d -print0)
        )
      fi
    done

    # Garbage collection runs only after every use of the ephemeral Git helper.
    # This prevents collection of the store path that the running script uses.
    #
    nix-collect-garbage -d
    sudo find /nix/var/nix/gcroots -xtype l -exec rm -v {} +;
    nix store gc -v
    nix store optimise -v
    echo ""

    # macOS system update; we do this last as this command may force a
    # reboot
    #
    if [[ "$OS" == "Darwin" ]]; then
      softwareupdate -ia --include-config --include-config-data
    fi

    # Mark script finish; this makes it easier to tell when an error has
    # occurred
    #
    echo "~*~ Update Complete ~*~"
  '';
}
