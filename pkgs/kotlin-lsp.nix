{
  writeShellApplication,
  kotlin-language-server,
}:
writeShellApplication {
  name = "kotlin-lsp";

  runtimeInputs = [
    kotlin-language-server
  ];

  text = ''
    exec kotlin-language-server "$@"
  '';
}
