{
  config,
  pkgs,
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
    ../programs/delta.nix # Requires bat.nix and git.nix
    ../programs/direnv.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/glow.nix
    ../programs/helix.nix
    ../programs/jq.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/zoxide.nix
  ];

  programs.yt-dlp.enable = true;

  home.packages = with pkgs; [
    android-tools
    chafa
    curlFull
    eza # Don't use programs.eza.enable because aliases differ between fish and bash/zsh
    ffmpeg-full
    gawk
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
    xz
    zip

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  xdg = {
    enable = true;

    # Is it weird not to make these directories hidden? Maybe, but it
    # also makes them slightly easier to work with.
    #
    cacheHome = "${config.home.homeDirectory}/cache";
    configHome = "${config.home.homeDirectory}/config";
    dataHome = "${config.home.homeDirectory}/local/share";
    stateHome = "${config.home.homeDirectory}/local/state";
  };
  home.preferXdgDirectories = true;

  # https://github.com/nix-community/home-manager/issues/7935#issuecomment-3671184459
  #
  manual.manpages.enable = false;
}
