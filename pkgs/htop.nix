{
  writeShellApplication,
  bottom,
}:
writeShellApplication {
  name = "htop";

  runtimeInputs = [
    bottom
  ];

  text = ''
    exec btm -b "$@"
  '';
}
