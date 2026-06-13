{pkgs, ...}: let
  localPkgs = {
    htop = pkgs.callPackage ./pkgs/htop.nix {};
    top = pkgs.callPackage ./pkgs/top.nix {};
  };
in {
  programs.bottom = {
    enable = true;

    settings = {
      styles = {
        theme = "gruvbox-light";
      };
    };
  };

  # Convenience wrappers
  #
  home.packages = [
    localPkgs.htop
    localPkgs.top
  ];
}
