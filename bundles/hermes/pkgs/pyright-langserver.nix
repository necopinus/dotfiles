{
  writeShellApplication,
  basedpyright,
}:
writeShellApplication {
  name = "pyright-langserver";

  runtimeInputs = [
    basedpyright
  ];

  text = ''
    exec basedpyright-langserver "$@"
  '';
}
