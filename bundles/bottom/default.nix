{
  lib,
  pkgs,
  ...
}: let
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

  # Hide desktop entry
  #
  xdg.desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    "bottom" = {
      name = "bottom";
      noDisplay = true;
      settings = {
        Hidden = "true";
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
