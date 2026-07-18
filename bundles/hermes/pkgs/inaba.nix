{writeShellApplication}:
writeShellApplication {
  name = "inaba";

  text = ''
    if [[ -n "$(which hermes 2> /dev/null)" ]]; then
      exec hermes --tui "$@"
    else
      echo "No executable 'hermes' binary found in PATH"
      exit 1
    fi
  '';
}
