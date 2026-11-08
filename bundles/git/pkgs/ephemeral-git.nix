{
  writeShellApplication,
  coreutils,
  pkgs,
  lib,
}: let
  ephemeralSshAgent = pkgs.callPackage ./ephemeral-ssh-agent.nix {};
  ephemeralPassCli = pkgs.callPackage ./ephemeral-pass-cli.nix {};
in
  writeShellApplication {
    name = "ephemeral-git";

    runtimeInputs = [coreutils];

    text = lib.strings.removeSuffix "\n" ''
      original_args=("$@")

      # Session markers are internal to this helper chain. Refuse stale or
      # inherited markers rather than loading the key into the wrong agent.
      if [[ -n "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
        if [[ -z "''${EPHEMERAL_SSH_AGENT_DIR:-}" || -z "''${SSH_AUTH_SOCK:-}" || "$SSH_AUTH_SOCK" != "$EPHEMERAL_SSH_AGENT_DIR/socket" || ! -S "$SSH_AUTH_SOCK" ]]; then
          echo "ephemeral-git: session markers do not match a live temporary agent" >&2
          exit 1
        fi
      fi

      if [[ "$#" -gt 0 && "$1" == "--batch" ]]; then
        shift
        if [[ "$#" -eq 0 ]]; then
          echo "ephemeral-git: --batch requires a command" >&2
          exit 1
        fi
        if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
          # Batch jobs can run much longer than interactive Git commands. The
          # command-mode agent still exits when the batch ends or is killed.
          export EPHEMERAL_SSH_AGENT_TIMEOUT="''${EPHEMERAL_SSH_AGENT_TIMEOUT:-86400}"
          export EPHEMERAL_SSH_AGENT_IDENTITY_TIMEOUT="''${EPHEMERAL_SSH_AGENT_IDENTITY_TIMEOUT:-86400}"
          exec ${ephemeralSshAgent}/bin/ephemeral-ssh-agent "$0" --batch "$@"
        fi
        if [[ "''${EPHEMERAL_GIT_KEY_READY:-0}" != 1 ]]; then
          PORTABLE_SSH_KEY="$(${ephemeralPassCli}/bin/ephemeral-pass-cli)"
          export PORTABLE_SSH_KEY
          export EPHEMERAL_GIT_KEY_READY=1
        fi
        exec "$@"
      fi

      use_portable_key=0
      expect_option_value=0
      subcommand=""
      subcommand_arg=""
      for argument in "$@"; do
        if [[ "$expect_option_value" -eq 1 ]]; then
          expect_option_value=0
          continue
        fi
        case "$argument" in
        -C | -c | --git-dir | --work-tree | --namespace | --config-env | --super-prefix)
          expect_option_value=1
          ;;
        -*)
          ;;
        *)
          if [[ -z "$subcommand" ]]; then
            subcommand="$argument"
          else
            subcommand_arg="$argument"
            break
          fi
          ;;
        esac
      done

      # Resolve simple Git aliases without attempting to interpret shell
      # functions. Plumbing and aliases that expand to shell code stay direct.
      if [[ -n "$subcommand" ]]; then
        alias_definition="$(git config --get "alias.$subcommand" 2>/dev/null || true)"
        if [[ -n "$alias_definition" && "$alias_definition" != \!* ]]; then
          read -r alias_command _ <<<"$alias_definition"
          subcommand="$alias_command"
        fi
      fi

      case "$subcommand" in
      commit | pull | push | fetch | clone | merge | rebase | cherry-pick | revert | am | ls-remote)
        use_portable_key=1
        ;;
      submodule)
        case "$subcommand_arg" in
        add | update)
          use_portable_key=1
          ;;
        esac
        ;;
      remote)
        case "$subcommand_arg" in
        update | prune | show)
          use_portable_key=1
          ;;
        esac
        ;;
      notes)
        case "$subcommand_arg" in
        fetch | push)
          use_portable_key=1
          ;;
        esac
        ;;
      archive)
        for argument in "''${original_args[@]}"; do
          case "$argument" in
          --remote | --remote=*)
            use_portable_key=1
            ;;
          esac
        done
        ;;
      tag)
        # Only annotated or explicitly signed tag creation needs the key.
        for argument in "''${original_args[@]}"; do
          case "$argument" in
          -a* | -s* | -u* | -m* | -F* | -e* | --annotate | --sign | --gpg-sign | --gpg-sign=* | --message | --file | --edit)
            use_portable_key=1
            ;;
          --no-gpg-sign)
            use_portable_key=0
            break
            ;;
          esac
        done
        ;;
      esac

      if [[ "$use_portable_key" -eq 0 ]]; then
        exec git "''${original_args[@]}"
      fi

      if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
        exec ${ephemeralSshAgent}/bin/ephemeral-ssh-agent "$0" "''${original_args[@]}"
      fi

      if [[ "''${EPHEMERAL_GIT_KEY_READY:-0}" != 1 ]]; then
        PORTABLE_SSH_KEY="$(${ephemeralPassCli}/bin/ephemeral-pass-cli)"
        export PORTABLE_SSH_KEY
        export EPHEMERAL_GIT_KEY_READY=1
      fi

      exec env GIT_SSH_COMMAND="ssh -i /dev/null" git -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$PORTABLE_SSH_KEY" "''${original_args[@]}"
    '';
  }
