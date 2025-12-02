{writeShellApplication}:
writeShellApplication {
  name = "update-system";

  text = ''
    set -e

    # System packages
    #
    if [[ -n "$(which apt 2> /dev/null)" ]]; then
      # Attempt to recover from crashes during configuration
      #
      sudo dpkg --configure --pending
      sudo apt install --fix-broken

      # Actual update
      #
      sudo apt update --fix-missing
      sudo apt full-upgrade
      sudo apt autoremove --purge --autoremove
      sudo apt clean
    fi

    # Update Nix packages
    #
    (
      cd "$HOME/config/nix"
      nix flake update
      nix flake archive
      git add -A -v
      git commit -m "Automated system update: $(date)" || true
      git push
      if [[ "$(uname -s)" == "Darwin" ]]; then
        sudo darwin-rebuild switch --flake .#macos
      else
        home-manager switch --flake .#android
      fi
    )

    # Update Helix grammars
    #
    hx -g fetch
    hx -g build

    # Need to set up GPG environment here to work around issues on some
    # systems
    #
    GPG_TTY="$(tty)"
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

    export GPG_TTY SSH_AUTH_SOCK
    gpg-connect-agent updatestartuptty /bye

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
    if [[ "$(uname -s)" == "Darwin" ]]; then
      softwareupdate --install --all --include-config --include-config-data
    fi
  '';
}
