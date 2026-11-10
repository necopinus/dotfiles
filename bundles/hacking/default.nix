{pkgs, ...}: {
  home.packages = with pkgs; [
    solc-select
  ];
}
