{ config, pkgs, ... }:
let
  extraNodePkgs = import ../pkgs/node/default.nix {};
  extraPythonPkgs = import ../pkgs/python/python-packages.nix {};
in {
  # imports = [
  #   ../programs/foo.nix
  # ];

  home.packages = with pkgs; [
    # Remove:
    #   .default-gems
    #   .default-npm-packages
    #   .default-python-packages
    #   config/mise
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
    ansible-language-server
    awk-language-server
    bash-language-server
    buf
    docker-compose-language-service
    dockerfile-language-server-nodejs
    fish-lsp
    gopls
    graphql-language-service-cli
    haskell-language-server
    jdt-language-server
    jq-lsp
    kotlin-language-server
    lua-language-server
    markdown-oxide
    marksman
    nil
    nixd
    nodePackages.prettier
    perlnavigator
    protols
    python313Packages.python-lsp-server
    ruby-lsp
    rubyPackages.solargraph
    ruff
    rust-analyzer
    solc
    sourcekit-lsp
    superhtml
    taplo
    texlab
    ts_query_ls
    ty
    typescript-language-server
    vscode-langservers-extracted
    wasm-language-tools
    yaml-language-server
    #### LSPs ####

    #### Formatters ####
    bibtex-tidy
    shellcheck
    shfmt
    swift-format
    #### Formatters ####

    extraPythonPkgs.qobuz-dl
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
