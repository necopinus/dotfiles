{pkgs, ...}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
    plistwatch

    #### Desktop apps ####
    #calibre         # Marked as broken
    #discord         # Always fails to install updates
    #handbrake-app   # Marked as broken
    protonmail-desktop
    #scroll-reverser # Flagged as "damaged" by macOS, won't open
    slack
    #stellarium      # Marked as broken
    xld

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

  # Home-manager won't allow xdg.userDirs on macOS, so we include our
  # own
  #
  xdg.configFile."user-dirs.dirs".source = ../artifacts/config/user-dirs.dirs;
}
