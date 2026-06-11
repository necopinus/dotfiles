{
  config,
  pkgs,
  lib,
  ...
}: let
  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix {};
    update-system = pkgs.callPackage ../pkgs/update-system.nix {};
  };
in {
  imports = [
    ../programs/bash.nix
    ../programs/bat.nix
    ../programs/bottom.nix
    ../programs/dircolors.nix
    ../programs/eza.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/helix.nix
    ../programs/jaq.nix
    ../programs/media-tools.nix
    ../programs/nodejs.nix
    ../programs/python.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/utils.nix
    ../programs/zellij.nix # Depends on fish.nix
    ../programs/zoxide.nix
  ];

  home.packages = with pkgs; [
    android-tools
    libqalculate
    msgpack-tools

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      setSessionVariables = true;

      # Reset the XDG_VIDEOS_DIR on macOS, since it uses ~/Movies
      #
      videos =
        if pkgs.stdenv.isDarwin
        then "${config.home.homeDirectory}/Movies"
        else "${config.home.homeDirectory}/Videos";
    };
  };
  home.preferXdgDirectories = true;

  # XDG_CONFIG_DIRS and XDG_DATA_DIRS are set here rather than in
  # xdg.systemDirs in order to avoid as much path messiness as possible
  #
  # IMPORTANT: We don't add the Nix profile XDG data dirs to
  # XDG_DATA_DIRS, as these will be appended to the end automatically
  # by /etc/profile.d/nix.sh
  #
  # XDG_*_HOME variables are set here to ensure their availability in
  # all shells
  #
  home.sessionVariables = {
    XDG_CONFIG_DIRS = "/etc/xdg:${config.home.homeDirectory}/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg";
    XDG_DATA_DIRS = lib.mkForce "/usr/local/share:/usr/share/gnome:/usr/share";

    XDG_CACHE_HOME = "${config.xdg.cacheHome}";
    XDG_CONFIG_HOME = "${config.xdg.configHome}";
    XDG_DATA_HOME = "${config.xdg.dataHome}";
    XDG_STATE_HOME = "${config.xdg.stateHome}";
  };

  # https://github.com/nix-community/home-manager/issues/7935#issuecomment-3671184459
  #
  manual.manpages.enable = false;
}
