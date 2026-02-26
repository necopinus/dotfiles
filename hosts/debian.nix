{pkgs, ...}: {
  home.packages = with pkgs; [
    dconf2nix
    pop-wallpapers
  ];

  #dconf.settings = {};
}
