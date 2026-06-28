{
  writeShellApplication,
  basedpyright,
}:
writeShellApplication {
  name = "pyright";

  runtimeInputs = [
    basedpyright
  ];

  text = ''
    exec basedpyright "$@"
  '';
}
