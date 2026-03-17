{
  config,
  pkgs,
  ...
}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/keepassxc.nix
    ../programs/zed.nix
    ../programs/zsh.nix
  ];

  programs.gpg.enable = true;

  home.packages = with pkgs; [
    plistwatch

    #### Desktop apps not available through Homebrew ####
    xld

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

  # UTM SSH convenience setup
  #
  programs.ssh = {
    matchBlocks."debian" = {
      host = "debian";
      user = "droid";
      hostname = "127.0.0.1";
      port = 2222;
      extraOptions = {
        RequestTTY = "yes";
        RemoteCommand = "/home/droid/.nix-profile/bin/zellij attach -c";
      };
      compression = true;
      forwardAgent = false;
      serverAliveInterval = 15;
      serverAliveCountMax = 4;
    };
  };

  # This *looks* like it should supress hint messages, but doesn't...
  #
  #   https://docs.brew.sh/Brew-Bundle-and-Brewfile?pubDate=20251207#advanced-brewfiles
  #
  home.sessionVariables.HOMEBREW_NO_ENV_HINTS = 1;
}
