{ pkgs, ... }:
let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix { };
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix { };
  };
in {
  # imports = [
  #   ../programs/foo.nix
  # ];

  home.packages = with pkgs; [
    localPkgs.pbcopy
    localPkgs.pbpaste
  ];

  # Make sure that the home-manager binary is available in the PATH
  #
  programs.home-manager.enable = true;

  # programs.example = {
  #   enable = true;
  # };

  # home.file = {
  #   ".config.foo".source = ../artifacts/config.foo;
  # };

  # home.sessionVariables = {
  #   FOO_VARIABLE = "bar";
  # };
}
