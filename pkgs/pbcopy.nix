{
  writeShellApplication,
  wl-clipboard,
  xsel,
}:
writeShellApplication {
  name = "pbcopy";

  runtimeInputs = [
    wl-clipboard
    xsel
  ];

  text = ''
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
      exec wl-copy "$@"
    elif [[ -n "$DISPLAY" ]]; then
      exec xsel -i -b "$@"
    elif [[ -d /run/user/$UID ]]; then
      echo -n "$@" > /run/user/$UID/.pasteboard
    else
      echo -n "$@" > /tmp/.$UID-pasteboard
    fi
  '';
}
