{
  writeShellApplication,
  jaq,
}:
writeShellApplication {
  name = "yq";

  runtimeInputs = [
    jaq
  ];

  text = ''
    exec jaq "$@"
  '';
}
