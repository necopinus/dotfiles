{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # Set in flake.nix overlay

  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix {};
    update-system = pkgs.callPackage ../pkgs/update-system.nix {};
  };
in {
  imports = [
    ../programs/bash.nix
    ../programs/bat.nix
    ../programs/bottom.nix
    ../programs/delta.nix # Requires bat.nix
    ../programs/dircolors.nix
    ../programs/direnv.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/glow.nix
    ../programs/helix.nix
    ../programs/jq.nix
    ../programs/less.nix
    ../programs/rclone.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/wezterm.nix # Requires fish.nix
    ../programs/zed.nix
    ../programs/zoxide.nix
  ];

  programs.pandoc.enable = true;
  programs.ripgrep.enable = true;
  programs.uv.enable = true;
  programs.yt-dlp.enable = true;

  home.packages = with pkgs; [
    android-tools
    brave
    chafa
    colorized-logs
    curlFull
    dos2unix
    expect
    eza # Don't use programs.eza.enable because aliases differ between fish and bash/zsh
    gawk
    gnutar
    imagemagick
    ipcalc
    less
    libjpeg
    libqalculate
    llmAgents.goose-cli # Set in flake.nix overlay
    msgpack-tools
    optipng
    poppler-utils
    rsgain
    rsync
    sqlite
    texliveFull # Can't figure out how to get programs.texlive to work...
    unzip
    util-linux
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

    cacheHome = "${config.home.homeDirectory}/cache";
    configHome = "${config.home.homeDirectory}/config";
    dataHome = "${config.home.homeDirectory}/local/share";
    stateHome = "${config.home.homeDirectory}/local/state";
  };

  # https://github.com/nix-community/home-manager/issues/7935#issuecomment-3671184459
  #
  manual.manpages.enable = false;

  # Environment variables
  #
  home.sessionVariables.VISUAL = "hx";
}
