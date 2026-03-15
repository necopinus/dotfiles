{
  writeShellApplication,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "zellij-post-command-discovery-hook";

  runtimeInputs = [
    uutils-coreutils-noprefix
  ];

  # Remove "nounset" from the default list, as we need to test against
  # the (potentially unset) ZELLIJ_SESSION_NAME environment variable
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

  text = ''
    # Parent processes that should be returned instead of child
    # processes
    #
    PREFERRED_PARENTS=(
      "hx"
    )

    # This wrapper must be launched from within a Zellij session
    if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
      echo "This tool must be run from within Zellij!"
      exit 1
    fi

    # We expect that the RESURRECT_COMMAND environment variable is set
    #
    #   https://zellij.dev/documentation/options.html#post_command_discovery_hook
    #
    if [[ -z "$RESURRECT_COMMAND" ]]; then
      echo "Expected the RESURRECT_COMMAND environment variable to be set!"
      exit 1
    fi

    # FIXME: We might have two processes that both match
    # RESURRECT_COMMAND. How do we distinguish which one we're
    # interested in? Right now, if ANY one of these processes
    # has a parent in PREFERRED_PARENTS, then all process will be
    # matched to that parent (and if multiple parents are matched, then
    # the last one will win)
    #
    for PID in $(pgrep -f "$RESURRECT_COMMAND"); do
      PARENT_PROCESS="$(ps -p "$(ps -p "$PID" -o ppid=)" -o comm=)"
      for PREFERRED_PARENT in "''${PREFERRED_PARENTS[@]}"; do
        if [[ "$PARENT_PROCESS" == "$PREFERRED_PARENT" ]] || [[ "$PARENT_PROCESS" == */"$PREFERRED_PARENT" ]]; then
          RESURRECT_COMMAND="$PARENT_PROCESS"
        fi
      done
    done

    echo "$RESURRECT_COMMAND"
  '';
}
