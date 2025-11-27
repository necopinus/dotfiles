{pkgs, ...}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
  };
in {
  imports = [
    ../programs/abcde.nix
  ];

  home.packages = with pkgs; [
    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji

    #### Local packages (see above) ####
    localPkgs.pbcopy
    localPkgs.pbpaste
  ];

  # Make sure that the home-manager binary is available in the PATH
  #
  programs.home-manager.enable = true;

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig.enable = true;

  # programs.example = {
  #   enable = true;
  # };

  # home.file = {
  #   ".config.foo".source = ../artifacts/config.foo;
  # };

  # home.sessionVariables = {
  #   FOO_VARIABLE = "bar";
  # };
}
