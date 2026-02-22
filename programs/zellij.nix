{
  pkgs,
  lib,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
  };
in {
  programs.zellij = {
    enable = true;

    # Don't enable the default shell integrations, as bespoke
    # integrations are used in bash.nix and zsh.nix (and fish shouldn't
    # use integration at all, as that's what we launch using Zellij)
    #
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;

    #attachExistingSession = true;
    #exitShellOnExit = true;

    settings = {
      default_shell = "${pkgs.fish}/bin/fish";
      copy_command = "pbcopy";
    };
  };

  # Install pbcopy script on Linux
  #
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    localPkgs.pbcopy
  ];
}
