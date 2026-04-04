{
  writeShellApplication,
  uutils-coreutils-noprefix,
  zellij,
}:
writeShellApplication {
  name = "zellij-launch-ide";

  runtimeInputs = [
    uutils-coreutils-noprefix
    zellij
  ];

  # Remove "nounset" from the default list, as we need to test against
  # the (potentially unset) ZELLIJ_SESSION_NAME environment variable
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

  text = ''
    # This wrapper must be launched from within a Zellij session
    #
    if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
      echo "This IDE must be launched from within Zellij!"
      exit 1
    fi

    if [[ $# -eq 0 ]]; then
      # If we weren't given any arguments, open the IDE in the current
      # directory (assuming that the current directory is fully
      # accessibly by the current user)
      #
      IDE_DIR="$(realpath "$(pwd)")"

      if [[ ! -r "$IDE_DIR" ]] || [[ ! -w "$IDE_DIR" ]] || [[ -x "$IDE_DIR" ]]; then
        IDE_DIR=""
      fi
    else
      # If we were given some set of arguments, find the first one that
      # points to a directory that is fully accessible by the current
      # user. If a file is found, we check if its enclosing directory
      # has the right permissions
      #
      IDE_DIR=""

      for OBJECT in "$@"; do
        if [[ -e "$OBJECT" ]]; then
          OBJECT="$(realpath "$OBJECT")"
          if [[ ! -d "$OBJECT" ]]; then
            OBJECT="$(dirname "$OBJECT")"
          fi
          if [[ -r "$OBJECT" ]] && [[ -w "$OBJECT" ]] && [[ -x "$OBJECT" ]]; then
              IDE_DIR="$OBJECT"
              break
          fi
        fi
      done
    fi

    if [[ -z "$IDE_DIR" ]]; then
      # If IDE_DIR is the empty string, then we didn't find a valid path
      #
      echo "The current directory is not a valid project directory, and no valid"
      echo "project directory was provided!"
      exit 1
    else
      echo "Opening project directory: $IDE_DIR"
      zellij action new-tab -c "$IDE_DIR" -l ide -n "IDE :: $IDE_DIR" > /dev/null
    fi
  '';
}
