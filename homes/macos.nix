{
  config,
  pkgs,
  ...
}: let
in {
  imports = [
    ../programs/rclone.nix
    ../programs/zed.nix
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
    plistwatch

    #### Desktop apps not available through Homebrew ####
    xld
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
