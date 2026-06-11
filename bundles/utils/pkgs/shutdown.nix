{writeShellApplication}:
writeShellApplication {
  name = "shutdown";

  text = ''
    exec /usr/bin/sudo /sbin/shutdown -h now
  '';
}
