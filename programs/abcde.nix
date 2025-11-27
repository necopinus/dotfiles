{pkgs, ...}: {
  home.packages = with pkgs; [
    abcde
    eject
    normalize
  ];

  home.file.".abcde.conf".source = ../artifacts/abcde.conf;
}
