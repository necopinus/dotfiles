{
  writeShellApplication,
  jaq,
}:
writeShellApplication {
  name = "jq";

  runtimeInputs = [
    jaq
  ];

  text = ''
    exec jaq "$@"
  '';
}
