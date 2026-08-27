{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../bundles/keepassxc
    ../../bundles/zsh
  ];

  home.packages = with pkgs; [
    android-tools
    dos2unix
    libqalculate
    plistwatch
    texliveMedium # Closest Nixpkgs to Debian's `texlive`
  ];

  # Explicitly prevent man cache generation on macOS, as this doesn't
  # work properly, generates errors, and is enabled by some packages
  #
  programs.man.generateCaches = false;

  # XDG user directory mapping for macOS
  #
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    videos = "${config.home.homeDirectory}/Movies";
  };
}
