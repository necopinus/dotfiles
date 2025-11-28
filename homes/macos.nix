{pkgs, ...}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  imports = [
    ../programs/gpg.nix
  ];

  # programs.example = {
  #   enable = true;
  # };

  home.packages = with pkgs; [
    protonmail-desktop
    slack
    xld

    #### Local packages (see above) ####
    localPkgs.vault-sync
  ];

  # home.file = {
  #   ".config.foo".source = ../artifacts/config.foo;
  # };

  # home.sessionVariables = {
  #   FOO_VARIABLE = "bar";
  # };
}
