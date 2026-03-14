{
  writeShellApplication,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "xcv";

  runtimeInputs = [uutils-coreutils-noprefix];

  text = ''
    nohup -- "$@" 2>/dev/null &
  '';
}
