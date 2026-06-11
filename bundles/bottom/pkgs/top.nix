{
  writeShellApplication,
  bottom,
}:
writeShellApplication {
  name = "top";

  runtimeInputs = [
    bottom
  ];

  text = ''
    exec btm -b "$@"
  '';
}
