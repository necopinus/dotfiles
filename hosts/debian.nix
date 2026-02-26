{pkgs, ...}: {
  home.packages = with pkgs; [
    dconf2nix
  ];

  dconf.settings = {};
}
