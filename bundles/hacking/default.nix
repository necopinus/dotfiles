{pkgs, ...}: {
  home.packages = with pkgs; [
    jadx
    solc-select
  ];
}
