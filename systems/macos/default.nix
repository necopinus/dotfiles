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
    plistwatch
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

  # UTM SSH convenience setup
  #
  programs.ssh.settings."linux-vm" = {
    User = "${config.home.username}";
    Hostname = "127.0.0.1";
    Port = 2222;
    RequestTTY = "yes";
    RemoteCommand = "/home/droid/.nix-profile/bin/zellij attach -c";
  };
}
