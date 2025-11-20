{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  # Home Manager state version
  home.stateVersion = "25.05";

  # User information
  home.username = "droid";
  home.homeDirectory = "/home/droid";

  # Android Debian VM-specific packages
  # home.packages = with pkgs; [
  #   # Android Debian VM-specific tools
  # ];

  # Android Debian VM-specific program configuration
  # programs.example = {
  #   enable = true;
  #   # Android Debian VM-specific settings
  # };

  # Android Debian VM-specific dotfiles
  # home.file = {
  #   ".config/debian-app/config".source = ../artifacts/debian-specific-config;
  # };

  # Android Debian VM-specific environment variables
  # home.sessionVariables = {
  #   # EXAMPLE_VAR = "debian-value";
  # };
}
