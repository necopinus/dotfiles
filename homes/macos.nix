{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  # Home Manager state version
  home.stateVersion = "25.05";

  # User information
  home.username = "necopinus";
  home.homeDirectory = "/Users/necopinus";

  # macOS-specific packages
  # home.packages = with pkgs; [
  #   # macOS-specific tools
  # ];

  # macOS-specific program configuration
  # programs.example = {
  #   enable = true;
  #   # macOS-specific settings
  # };

  # macOS-specific dotfiles
  # home.file = {
  #   ".config/macos-app/config".source = ../artifacts/macos-specific-config;
  # };

  # macOS-specific environment variables
  # home.sessionVariables = {
  #   # EXAMPLE_VAR = "macos-value";
  # };
}
