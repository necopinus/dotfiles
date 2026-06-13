{
  writeShellApplication,
  lib,
  stdenv,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "pbpaste";

  runtimeInputs = lib.optionals stdenv.isLinux [
    uutils-coreutils-noprefix
  ];

  text =
    if stdenv.isDarwin
    then ''
      exec /usr/bin/pbpaste "$@"
    ''
    else ''
      if [[ -f /run/user/$UID/.pasteboard ]]; then
        cat /run/user/$UID/.pasteboard
      elif [[ -f /tmp/.pasteboard-$UID ]]; then
        cat /tmp/.pasteboard-$UID
      fi
    '';
}
