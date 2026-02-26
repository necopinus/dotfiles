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

  # Futile attempt to suppress Homebrew hint messages
  #
  home.sessionVariables.HOMEBREW_NO_ENV_HINTS = 1;
}
