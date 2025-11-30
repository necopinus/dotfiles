{pkgs, ...}: {
  programs.dircolors = {
    enable = true;
    package = pkgs.uutils-coreutils-noprefix;
  };
}
