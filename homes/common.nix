{ config, pkgs, ... }:

{
  # imports = [
  #   ../programs/foo.nix
  # ];

  home.packages = with pkgs; [
    libqalculate
    openvpn
  ];

  # Git configuration (example of shared settings)
  #
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #   };
  # };

  # Shell configuration (example)
  #
  # programs.bash = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };

  # programs.zsh = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };

  # Dotfile management (example)
  #
  # home.file = {
  #   ".config/example/config.toml".source = ../artifacts/config/example/config.toml;
  # };

  # Environment variables
  #
  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };
}
