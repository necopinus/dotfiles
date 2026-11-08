{
  writeShellApplication,
  coreutils,
  proton-pass-cli,
  lib,
}:
writeShellApplication {
  name = "ephemeral-pass-cli";

  runtimeInputs = [
    coreutils
    proton-pass-cli
  ];

  text = lib.strings.removeSuffix "\n" ''
    pass_cli="''${EPHEMERAL_PASS_CLI_BIN:-pass-cli}"
    portable_dir=""
    public_key=""
    watchdog_pid=""
    command_pid=""

    cleanup() {
      local exit_status="''${1:-$?}"
      trap - EXIT
      if [[ -n "$command_pid" ]]; then
        kill "$command_pid" >/dev/null 2>&1 || true
      fi
      if [[ -n "$watchdog_pid" ]]; then
        pkill -KILL -P "$watchdog_pid" >/dev/null 2>&1 || true
        kill "$watchdog_pid" >/dev/null 2>&1 || true
      fi
      if [[ -n "''${portable_dir:-}" && -d "$portable_dir" ]]; then
        if [[ -n "''${PORTABLE_PAT:-}" ]]; then
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$portable_dir" "$pass_cli" logout --force >/dev/null 2>&1 || true
        fi
        rm -rf "$portable_dir" || true
      fi
      exit "$exit_status"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    run_with_timeout() {
      local seconds="$1"
      local command_status=0

      run_pass_cli &
      command_pid=$!
      (
        sleep "$seconds"
        kill -TERM "$command_pid" >/dev/null 2>&1 || true
        sleep 10
        pkill -KILL -P "$command_pid" >/dev/null 2>&1 || true
        kill -KILL "$command_pid" >/dev/null 2>&1 || true
      ) >/dev/null 2>&1 &
      watchdog_pid=$!
      disown "$watchdog_pid"

      wait "$command_pid" || command_status=$?
      command_pid=""
      pkill -KILL -P "$watchdog_pid" >/dev/null 2>&1 || true
      kill "$watchdog_pid" >/dev/null 2>&1 || true
      return "$command_status"
    }

    run_pass_cli() {
      if [[ -n "''${PORTABLE_PAT:-}" ]]; then
        if ! env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$portable_dir" "$pass_cli" login >&2; then
          echo "ephemeral-pass-cli: unable to log in to Proton Pass" >&2
          return 1
        fi
        if ! public_key="$(env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$portable_dir" "$pass_cli" item view "pass://Portable/SSH :: Portable/Public key")"; then
          echo "ephemeral-pass-cli: unable to read the portable SSH public key" >&2
          return 1
        fi
      else
        # The no-PAT branch keeps the existing persistent login. Use the
        # required item lookup as the session check, not `pass-cli info`.
        if ! public_key="$(env -u PROTON_PASS_PERSONAL_ACCESS_TOKEN "$pass_cli" item view "pass://Portable/SSH :: Portable/Public key")"; then
          if ! env -u PROTON_PASS_PERSONAL_ACCESS_TOKEN "$pass_cli" login >&2; then
            echo "ephemeral-pass-cli: unable to log in to Proton Pass" >&2
            return 1
          fi
          if ! public_key="$(env -u PROTON_PASS_PERSONAL_ACCESS_TOKEN "$pass_cli" item view "pass://Portable/SSH :: Portable/Public key")"; then
            echo "ephemeral-pass-cli: unable to read the portable SSH public key" >&2
            return 1
          fi
        fi
      fi

      if [[ -z "$public_key" ]] || [[ "$public_key" == *$'\n'* ]]; then
        echo "ephemeral-pass-cli: Proton Pass returned an invalid SSH public key" >&2
        return 1
      fi

      if [[ -n "''${PORTABLE_PAT:-}" ]]; then
        if ! env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$portable_dir" "$pass_cli" ssh-agent load --vault-name Portable >&2; then
          echo "ephemeral-pass-cli: unable to load the portable SSH key" >&2
          return 1
        fi
        env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$portable_dir" "$pass_cli" logout --force >&2 || true
        rm -rf "$portable_dir"
        portable_dir=""
      else
        if ! env -u PROTON_PASS_PERSONAL_ACCESS_TOKEN "$pass_cli" ssh-agent load --vault-name Portable >&2; then
          echo "ephemeral-pass-cli: unable to load the portable SSH key" >&2
          return 1
        fi
      fi

      printf '%s\n' "$public_key"
    }

    if [[ -z "''${EPHEMERAL_GIT_SESSION:-}" ]]; then
      echo "ephemeral-pass-cli: run this helper inside ephemeral-ssh-agent" >&2
      exit 1
    fi
    if [[ -n "''${PORTABLE_PAT:-}" ]]; then
      portable_dir="$(mktemp -d)"
    fi

    command_status=0
    run_with_timeout "''${EPHEMERAL_PASS_CLI_TIMEOUT:-300}" || command_status=$?
    cleanup "$command_status"
  '';
}
