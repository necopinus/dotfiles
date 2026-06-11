{
  writeShellApplication,
  which,
}:
writeShellApplication {
  name = "nvim";

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
