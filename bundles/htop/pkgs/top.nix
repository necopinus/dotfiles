{
  writeShellApplication,
  htop,
}:
writeShellApplication {
  name = "top";

  runtimeInputs = [
    htop
  ];

  text = ''
    exec htop "$@"
  '';
}
