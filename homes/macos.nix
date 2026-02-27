{pkgs, ...}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/zed.nix
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
    plistwatch

    #### Desktop apps not available through Homebrew ####
    xld

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

  # This *looks* like it should supress hint messages, but doesn't...
  #
  #   https://docs.brew.sh/Brew-Bundle-and-Brewfile?pubDate=20251207#advanced-brewfiles
  #
  home.sessionVariables.HOMEBREW_NO_ENV_HINTS = 1;
}
