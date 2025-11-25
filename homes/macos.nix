{ config, pkgs, ... }:
let
  extraNodePkgs = import ../pkgs/node/default.nix {};
  extraPythonPkgs = import ../pkgs/python/python-packages.nix {};
in {
  # imports = [
  #   ../programs/foo.nix
  # ];

  # home.packages = with pkgs; [
  #   some-tool
  # ];

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
