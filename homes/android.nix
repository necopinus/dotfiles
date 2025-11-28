{pkgs, ...}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
  };
in {
  #imports = [
  #  ../programs/foo.nix
  #];

  # Make sure that the home-manager binary is available in the PATH
  #
  programs.home-manager.enable = true;

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    calibre
    obsidian

    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji

    #### Local packages (see above) ####
    localPkgs.pbcopy
    localPkgs.pbpaste
  ];

  home.file = {
    ".gnupg/gpg-agent.conf".source = ../artifacts/gnupg/gpg-agent.conf;

    # Disable default application startups
    #
    "config/autostart/light-locker.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "config/autostart/xiccd.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

    # Hide some desktop applications
    #
    "local/share/applications/fish.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/org.gnome.Vte.App.Gtk3.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/org.gnome.Vte.App.Gtk4.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/xfce4-terminal.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/zutty.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
  };

  # home.sessionVariables = {
  #   FOO_VARIABLE = "bar";
  # };
}
