{pkgs, ...}: let
  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix {};
    update-system = pkgs.callPackage ../pkgs/update-system.nix {};
  };
in {
  imports = [
    ../programs/bat.nix
    ../programs/helix.nix
    ../programs/zed.nix
  ];

  home.packages = with pkgs; [
    # Remove:
    #   .default-gems
    #   .default-npm-packages
    #   .default-python-packages
    #   bin/backup
    #   bin/pbcopy
    #   bin/pbpaste
    #   bin/update
    #   cache/env
    #   config/bat
    #   config/helix
    #   config/mise
    #   config/qobuz-dl
    #   config/zed
    #   local/state/mise
    #   local/share/fonts
    #   local/share/mise
    #
    # Modify:
    #   .profile
    #   bin/update
    #
    # Commands:
    #   sudo apt purge --autoremove --purge \
    #            android-sdk-platform-tools fonts-noto wl-clipboard
    #
    #   brew uninstall libqalculate openvpn xsel
    #
    #   brew uninstall android-platform-tools bat delve \
    #                  font-jetbrains-mono-nerd-font gopls \
    #                  haskell-language-server helix jdtls jq-lsp \
    #                  lua-language-server markdown-oxide mise pandoc \
    #                  ruff rust-analyzer shellcheck shfmt swift-format \
    #                  texlab tinymist zed

    android-tools
    libqalculate
    pandoc
    texliveFull
    yq
    yt-dlp

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  # Git configuration (example of shared settings)
  #
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #   };
  # };

  # Shell configuration (example)
  #
  # programs.bash = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };

  # programs.zsh = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -la";
  #   };
  # };

  # Additional dotfiles
  #
  home.file = {
    "config/marksman/config.toml".source = ../artifacts/config/marksman/config.toml;
  };

  # Environment variables
  #
  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };
}
