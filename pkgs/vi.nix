{
  writeShellApplication,
  which,
}:
writeShellApplication {
  name = "vi";

  runtimeInputs = [
    which
  ];

  # Remove "nounset" from the options default list, as EDITOR may be
  # unset
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

  text = ''
    exec $(which "''${EDITOR:-nano}") "$@"
  '';
}
