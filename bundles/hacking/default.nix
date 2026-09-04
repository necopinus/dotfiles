{pkgs, ...}: {
  home.packages = with pkgs; [
    #jadx # Dependencies frequently break
    solc-select
  ];
}
