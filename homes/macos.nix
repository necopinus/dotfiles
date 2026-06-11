{
  pkgs,
  config,
  ...
}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/keepassxc.nix
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
    plistwatch

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

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
