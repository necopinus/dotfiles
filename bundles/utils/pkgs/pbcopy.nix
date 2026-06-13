{
  writeShellApplication,
  lib,
  stdenv,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "pbcopy";

  runtimeInputs = lib.optionals stdenv.isLinux [
    uutils-coreutils-noprefix
  ];

  text =
    if stdenv.isDarwin
    then ''
      exec /usr/bin/pbcopy "$@"
    ''
    else ''
      if [[ -d /run/user/$UID ]]; then
        cat - > /run/user/$UID/.pasteboard
      else
        cat - > /tmp/.pasteboard-$UID
      fi
    '';
}
