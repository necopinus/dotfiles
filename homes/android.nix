{ config, pkgs, ... }:

{
  # imports = [
  #   ../programs/foo.nix
  # ];

  home.packages = with pkgs; [
    wl-clipboard
    xsel
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
