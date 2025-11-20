{ config, pkgs, ... }:

{
  # Disable nix-darwin's management of the nix binary (using determinate-nix)
  nix.enable = false;

  # Homebrew configuration (commented out initially)
  # homebrew = {
  #   enable = true;
  #   onActivation = {
  #     autoUpdate = true;
  #     upgrade = true;
  #     cleanup = "zap"; # uninstall formulae/casks not listed below
  #   };
  #   brews = [
  #     # "example-formula"
  #   ];
  #   casks = [
  #     # "example-app"
  #   ];
  # };

  # Platform-specific settings
  system.defaults = {
    # Example: dock settings
    # dock.autohide = true;
    # dock.mru-spaces = false;

    # Example: finder settings
    # finder.AppleShowAllExtensions = true;
    # finder.FXPreferredViewStyle = "Nlsv"; # list view
  };
}
