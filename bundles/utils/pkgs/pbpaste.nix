{
  writeShellApplication,
  stdenv,
}:
writeShellApplication {
  name = "pbpaste";

  text =
    if stdenv.hostPlatform.isDarwin
    then ''
      exec /usr/bin/pbpaste "$@"
    ''
    else ''
      if [[ -f /run/user/$UID/.pasteboard ]]; then
        cat /run/user/$UID/.pasteboard
      else
        pasteboard_dir="''${TMPDIR:-/tmp}/.pasteboard-$UID"
        if [[ -L "$pasteboard_dir" ]]; then
          echo "Refusing to read a symlinked clipboard directory" >&2
          exit 1
        fi
        if [[ -f "$pasteboard_dir/clipboard" ]]; then
          cat "$pasteboard_dir/clipboard"
        fi
      fi
    '';
}
