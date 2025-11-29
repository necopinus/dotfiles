{pkgs, ...}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/gpg.nix
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
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

  home.file = {
    "config/user-dirs.dirs".source = ../artifacts/config/user-dirs.dirs;
  };
}
