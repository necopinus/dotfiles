{ pkgs, ... }:
let
  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix { };
    update-system = pkgs.callPackage ../pkgs/update-system.nix { };
  };
in {
  imports = [
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
    #   config/helix
    #   config/mise
    #   config/qobuz-dl
    #   config/zed
    #   local/state/mise
    #   local/share/mise
    #
    # Modify:
    #   .profile
    #   bin/update
    #
    # Commands:
    #   sudo apt purge --autoremove --purge wl-clipboard
    #
    #   brew uninstall libqalculate openvpn xsel
    #
    #   brew uninstall delve gopls haskell-language-server helix jdtls \
    #                  jq-lsp lua-language-server markdown-oxide mise ruff \
    #                  rust-analyzer shellcheck shfmt swift-format texlab \
    #                  tinymist zed

    libqalculate
    localPkgs.backup-home
    localPkgs.update-system
    yq
    yt-dlp
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

  # Dotfile management (example)
  #
  # home.file = {
  #   ".config/example/config.toml".source = ../artifacts/config/example/config.toml;
  # };

  # Environment variables
  #
  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };
}
