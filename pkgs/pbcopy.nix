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
    else
      echo -n "$@" > /run/user/$UID/.pasteboard
    fi
  '';
}
