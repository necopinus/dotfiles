{
  writeShellApplication,
  bat,
}:
writeShellApplication {
  name = "less";

  runtimeInputs = [
    bat
  ];

  text = ''
    exec bat "$@"
  '';
}
