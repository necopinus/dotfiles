{
  writeShellApplication,
  wl-clipboard,
  xsel,
}:
writeShellApplication {
  name = "pbpaste";

  runtimeInputs = [
    wl-clipboard
    xsel
  ];

  text = ''
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
      exec wl-paste "$@"
    elif [[ -n "$DISPLAY" ]]; then
      exec xsel -o -b "$@"
    elif [[ -f /run/user/$UID/.pasteboard ]]; then
      cat /run/user/$UID/.pasteboard
    elif [[ -f /tmp/.pasteboard-$UID ]]; then
      cat /tmp/.pasteboard-$UID
    fi
  '';
}
