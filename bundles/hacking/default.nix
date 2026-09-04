{pkgs, ...}: {
  home.packages = with pkgs; [
    #jadx # Frequently breaks
    solc-select
  ];
}
