{
  writeShellApplication,
  lib,
  stdenv,
  uutils-coreutils-noprefix,
  wl-clipboard,
  xsel,
}:
writeShellApplication {
  name = "pbcopy";

  runtimeInputs =
    [
      uutils-coreutils-noprefix
    ]
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
      xsel
    ];

  # Remove "nounset" from the default list, as we need to test against
  # potentially unset environment variables (WAYLAND_DISPLAY and
  # DISPLAY)
  #
  bashOptions = [
    "errexit"
    "pipefail"
  ];

  text =
    (
      if stdenv.isLinux
      then ''
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
          exec wl-copy "$@"
        elif [[ -n "$DISPLAY" ]]; then
          exec xsel -i -b "$@"
      ''
      else ''
        if [[ -x /usr/bin/pbcopy ]]; then
          exec /usr/bin/pbcopy "$@"
      ''
    )
    + ''
      elif [[ -d /run/user/$UID ]]; then
        cat - > /run/user/$UID/.pasteboard
      else
        cat - > /tmp/.pasteboard-$UID
      fi
    '';
}
