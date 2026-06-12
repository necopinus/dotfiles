{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../bundles/keepassxc
    ../bundles/zsh
  ];

  home.packages = with pkgs; [
    plistwatch
  ];

  # XDG user directory mapping for macOS
  #
  xdg.userDirs = {
    enable = true;
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

  # This *looks* like it should supress hint messages, but doesn't...
  #
  #   https://docs.brew.sh/Brew-Bundle-and-Brewfile?pubDate=20251207#advanced-brewfiles
  #
  home.sessionVariables.HOMEBREW_NO_ENV_HINTS = 1;
}
