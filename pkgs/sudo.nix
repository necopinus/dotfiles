{writeShellApplication}:
writeShellApplication {
  name = "sudo";

  text = ''
    exec /usr/bin/sudo -E "$@"
  '';
}
