{ config, pkgs, ... }:

{
  # imports = [
  #   ../programs/foo.nix
  # ];

  home.packages = with pkgs; [
    # Remove:
    #   .default-gems
    #   .default-npm-packages
    #   .default-python-packages
    #   config/env
    #   config/mise
    #   config/qobuz-dl
    #   local/state/mise
    #   local/share/mise
    #
    # Modify:
    #   .profile
    #   bin/update
    #
    # Commands:
    #   brew uninstall delve gopls haskell-language-server jdtls jq-lsp \
    #                  lua-language-server markdown-oxide mise ruff \
    #                  rust-analyzer shellcheck shfmt swift-format texlab \
    #                  tinymist

    #### LSPs ####
    bash-language-server
    fish-lsp
    lua-language-server
    markdown-oxide
    marksman
    nil
    nixd
    python3Packages.python-lsp-server
    ruff
    solc
    superhtml
    taplo
    tombi
    ty
    typescript-language-server
    vscode-langservers-extracted
    wasm-language-tools
    yaml-language-server
    #### LSPs ####

    #### Formatters ####
    prettier
    shellcheck
    shfmt
    #### Formatters ####

    libqalculate
    openvpn
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
