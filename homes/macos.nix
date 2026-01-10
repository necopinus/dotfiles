{
  config,
  pkgs,
  ...
}: let
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
    #chatgpt         # Outdated
    #handbrake-app   # Marked as broken
    #scroll-reverser # Flagged as "damaged" by macOS, won't open
    #stellarium      # Marked as broken
    xld

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

  # Home-manager won't allow some XDG settings on macOS, so we roll them
  # by hand here
  #
  xdg.configFile."user-dirs.dirs".source = ../artifacts/config/user-dirs.dirs;
  home.sessionVariables.XDG_CONFIG_DIRS = "${config.home.homeDirectory}/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg";
  home.sessionVariables.XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share";

  # Futile attempt to suppress Homebrew hint messages
  #
  home.sessionVariables.HOMEBREW_NO_ENV_HINTS = 1;
}
