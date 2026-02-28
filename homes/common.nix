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
    ../programs/claude.nix
    ../programs/chafa.nix
    ../programs/delta.nix # Requires bat.nix and git.nix
    ../programs/dircolors.nix
    ../programs/direnv.nix
    ../programs/eza.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/glow.nix
    ../programs/helix.nix
    ../programs/jaq.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/zoxide.nix
  ];

  programs.yt-dlp.enable = true;

  home.packages = with pkgs; [
    android-tools
    curlFull
    ffmpeg-full
    gawk
    gnugrep
    gnutar
    imagemagick
    less
    libjpeg
    libqalculate
    msgpack-tools
    optipng
    poppler-utils
    rsgain
    rsync
    unzip
    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
    uutils-sed
    which
    xz
    zip

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;

      # Some XDG user directories need to be reset, as macOS
      # directories don't always match the spec and equivalent
      # directories in the Android VM live in /mnt/shared
      #
      # NOTE: We *don't* map the XDG_DOWNLOAD_DIR, as there's no way to
      # get a consistent host name between the Debian VMs (on an
      # Android host it will be /mnt/share/Download, while on a macOS
      # host it will be /mnt/share/Downloads)
      #
      documents =
        if pkgs.stdenv.isLinux
        then "/mnt/shared/Documents"
        else "${config.home.homeDirectory}/Documents";
      #download =
      #  if pkgs.stdenv.isLinux
      #  then "/mnt/shared/Download"
      #  else "${config.home.homeDirectory}/Downloads";
      music =
        if pkgs.stdenv.isLinux
        then "/mnt/shared/Music"
        else "${config.home.homeDirectory}/Music";
      pictures =
        if pkgs.stdenv.isLinux
        then "/mnt/shared/Pictures"
        else "${config.home.homeDirectory}/Pictures";
      videos =
        if pkgs.stdenv.isLinux
        then "/mnt/shared/Movies"
        else "${config.home.homeDirectory}/Movies";
    };
  };
  home.preferXdgDirectories = true;

  # XDG_CONFIG_DIRS and XDG_DATA_DIRS are set here rather than in
  # xdg.systemDirs in order to avoid as much path messiness as possible
  # and to allow for easy inclusion in systemd.user.sessionVariables
  # (debian.nix)
  #
  # XDG_*_HOME variables are set here to ensure their availability in
  # all shells
  #
  home.sessionVariables = {
    XDG_CONFIG_DIRS = "${config.home.homeDirectory}/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg";
    XDG_DATA_DIRS = lib.mkForce "${config.home.homeDirectory}/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share";

    XDG_CACHE_HOME = "${config.xdg.cacheHome}";
    XDG_CONFIG_HOME = "${config.xdg.configHome}";
    XDG_DATA_HOME = "${config.xdg.dataHome}";
    XDG_STATE_HOME = "${config.xdg.stateHome}";
  };

  # https://github.com/nix-community/home-manager/issues/7935#issuecomment-3671184459
  #
  manual.manpages.enable = false;
}
