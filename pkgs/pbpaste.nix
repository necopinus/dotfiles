{
  writeShellApplication,
  lib,
  stdenv,
  uutils-coreutils-noprefix,
  wl-clipboard,
  xsel,
}:
writeShellApplication {
  name = "pbpaste";

  runtimeInputs =
    [
      uutils-coreutils-noprefix
    ]
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
      xsel
    ];

  text =
    (
      if stdenv.isLinux
      then ''
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
          exec wl-paste "$@"
        elif [[ -n "$DISPLAY" ]]; then
          exec xsel -o -b "$@"
      ''
      else ''
        if [[ -x /usr/bin/pbpaste ]]; then
          exec /usr/bin/pbpaste "$@"
      ''
    )
    + ''
      elif [[ -f /run/user/$UID/.pasteboard ]]; then
        cat /run/user/$UID/.pasteboard
      elif [[ -f /tmp/.pasteboard-$UID ]]; then
        cat /tmp/.pasteboard-$UID
      fi
    '';
}
