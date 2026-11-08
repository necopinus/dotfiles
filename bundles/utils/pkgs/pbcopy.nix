{
  writeShellApplication,
  stdenv,
}:
writeShellApplication {
  name = "pbcopy";

  text =
    if stdenv.hostPlatform.isDarwin
    then ''
      exec /usr/bin/pbcopy "$@"
    ''
    else ''
      if [[ -d /run/user/$UID ]]; then
        cat - > /run/user/$UID/.pasteboard
      else
        # Keep the fallback clipboard in a private per-user directory. A
        # symlink here could redirect clipboard writes to another file.
        pasteboard_dir="''${TMPDIR:-/tmp}/.pasteboard-$UID"
        if [[ -L "$pasteboard_dir" ]]; then
          echo "Refusing to use a symlinked clipboard directory" >&2
          exit 1
        fi
        umask 077
        mkdir -p "$pasteboard_dir"
        chmod 700 "$pasteboard_dir"
        cat - > "$pasteboard_dir/clipboard"
      fi
    '';
}
