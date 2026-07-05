{lib, ...}: {
  programs.home-manager.enable = true; # Make sure that home-manager binary is in the PATH

  # Ironically, this designed to work with Debian-ish distros, not NixOS
  #
  targets.genericLinux.enable = true;

  # Generating the man page cache is safe on Linux
  #
  programs.man.generateCaches = true;

  # https://github.com/nix-community/home-manager/issues/2033
  #
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };
}
