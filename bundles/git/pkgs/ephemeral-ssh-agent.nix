{
  writeShellApplication,
  coreutils,
  openssh,
  gnused,
  lib,
}:
writeShellApplication {
  name = "ephemeral-ssh-agent";

  runtimeInputs = [
    coreutils
    openssh
    gnused
  ];

  text = lib.strings.removeSuffix "\n" ''
    agent_dir="''${EPHEMERAL_SSH_AGENT_DIR:-}"
    timeout_seconds="''${EPHEMERAL_SSH_AGENT_TIMEOUT:-900}"
    identity_timeout_seconds="''${EPHEMERAL_SSH_AGENT_IDENTITY_TIMEOUT:-600}"
    agent_pid=""
    watchdog_pid=""
    command_pid=""
    owns_agent=0

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
      if [[ -n "$agent_pid" ]]; then
        SSH_AGENT_PID="$agent_pid" ssh-agent -k >/dev/null 2>&1 || kill "$agent_pid" >/dev/null 2>&1 || true
      fi
      if [[ "$owns_agent" == 1 && -d "$agent_dir" ]]; then
        rm -rf "$agent_dir" || true
      fi

      exit "$exit_status"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    run_with_timeout() {
      local seconds="$1"
      shift
      local command_status=0

      "$@" &
      command_pid=$!
      (
        sleep "$seconds"
        kill -TERM "$command_pid" >/dev/null 2>&1 || true
        if [[ -n "$agent_pid" ]]; then
          kill -TERM "$agent_pid" >/dev/null 2>&1 || true
        fi
        sleep 10
        pkill -KILL -P "$command_pid" >/dev/null 2>&1 || true
        kill -KILL "$command_pid" >/dev/null 2>&1 || true
        if [[ -n "$agent_pid" ]]; then
          kill -KILL "$agent_pid" >/dev/null 2>&1 || true
        fi
      ) >/dev/null 2>&1 &
      watchdog_pid=$!
      disown "$watchdog_pid"

      wait "$command_pid" || command_status=$?
      command_pid=""
      pkill -KILL -P "$watchdog_pid" >/dev/null 2>&1 || true
      kill "$watchdog_pid" >/dev/null 2>&1 || true
      return "$command_status"
    }

    if [[ -z "$agent_dir" ]]; then
      agent_dir="$(mktemp -d)"
      export EPHEMERAL_SSH_AGENT_DIR="$agent_dir"
      export EPHEMERAL_GIT_SESSION=1
      eval "$(ssh-agent -a "$agent_dir/socket" -s -t "$identity_timeout_seconds" | sed '/^echo /d')"
      agent_pid="$SSH_AGENT_PID"
      owns_agent=1
    fi

    if [[ ! -S "$agent_dir/socket" ]]; then
      echo "ephemeral-ssh-agent: temporary agent socket is missing" >&2
      exit 1
    fi
    if [[ "$#" -eq 0 ]]; then
      echo "ephemeral-ssh-agent: no command was provided" >&2
      exit 1
    fi

    # Background execution preserves terminal access. The watchdog kills the
    # command and owned agent on timeout, while normal cleanup is explicit.
    command_status=0
    run_with_timeout "$timeout_seconds" "$@" || command_status=$?
    cleanup "$command_status"
  '';
}
