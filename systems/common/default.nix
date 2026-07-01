{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../bundles/bash
    ../../bundles/bat
    ../../bundles/eza
    ../../bundles/fish
    ../../bundles/git
    ../../bundles/helix
    ../../bundles/htop
    ../../bundles/media-tools
    ../../bundles/ssh
    ../../bundles/starship
    ../../bundles/tmux # Depends on ../bundles/fish
    ../../bundles/utils
    ../../bundles/zoxide
  ];

  programs.dircolors.enable = true;
  programs.npm.enable = true; # Just use Nix to avoid NodeJs package conflicts
  programs.ripgrep.enable = pkgs.stdenv.isDarwin; # Installed at the system level on Linux
  programs.uv.enable = true;

  home.packages = with pkgs;
    [
      msgpack-tools
      pnpm
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      dos2unix
    ];

  # Prefer to use ~/.cache, ~/.config, and ~/.local
  #
  xdg.enable = true;
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
