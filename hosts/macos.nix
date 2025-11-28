{pkgs, ...}: {
  # Disable nix-darwin's management of the nix binary, as I'm using
  # determinate-nix
  #
  nix.enable = false;

  # Use Touch ID with sudo (in all situations)
  #
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

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
  #     "adobe-creative-cloud"
  #     "calibre" # Version in nixpkgs marked as broken
  #     "claude"
  #     "discord" # Version in nixpkgs won't install updates
  #     "doppler-app"
  #     "github"
  #     "google-drive"
  #     "handbrake-app" # Version in nixpkgs marked as broken
  #     "makemkv"
  #     "obsidian"
  #     "proton-drive"
  #     "proton-pass"
  #     "protonvpn"
  #     "qflipper"
  #     "qobuz-downloader"
  #     "reader"
  #     "scroll-reverser" # Version in nixpkgs won't open
  #     "signal"
  #     "stellarium" # Version in nixpkgs marked as broken
  #     "todoist-app"
  #     "tresorit"
  #     "vlc"
  #     "yubico-yubikey-manager"
  #   ];
  # };

  # Fonts
  #
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji
  ];

  system.defaults = {
    # Example: dock settings
    # dock.autohide = true;
    # dock.mru-spaces = false;

    # Example: finder settings
    # finder.AppleShowAllExtensions = true;
    # finder.FXPreferredViewStyle = "Nlsv"; # list view
  };
}
