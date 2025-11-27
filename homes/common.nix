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
    #   ~/.abcde.conf
    #   ~/.default-gems
    #   ~/.default-npm-packages
    #   ~/.default-python-packages
    #   ~/bin/backup
    #   ~/bin/pbcopy
    #   ~/bin/pbpaste
    #   ~/bin/update
    #   ~/cache/env
    #   ~/config/bat
    #   ~/config/helix
    #   ~/config/mise
    #   ~/config/moxide
    #   ~/config/qobuz-dl
    #   ~/config/zed
    #   ~/local/state/mise
    #   ~/local/share/fonts
    #   ~/local/share/mise
    #   /etc/apt/sources.list.d/brave-browser.sources
    #   /usr/share/keyrings/brave-browser-archive-keyring.gpg
    #
    # Modify:
    #   ~/.profile
    #   ~/config/fish/config.fish (remove find/grep aliases)
    #
    # Commands:
    #   sudo apt purge --autoremove --purge \
    #            android-sdk-platform-tools brave-browser eject fonts-noto \
    #            wl-clipboard
    #
    #   brew uninstall libqalculate openvpn xsel
    #
    #   brew uninstall abcde android-platform-tools bat block-goose-cli \
    #                  brave-browser cd-discid delve eza fd fzf \
    #                  font-jetbrains-mono-nerd-font gawk gopls \
    #                  haskell-language-server helix jdtls jq-lsp less \
    #                  lua-language-server libyaml markdown-oxide mise \
    #                  normalize pandoc ripgrep rsgain ruff rust-analyzer \
    #                  shellcheck shfmt swift-format texlab tinymist \
    #                  uutils-coreutils uutils-diffutils uutils-findutils \
    #                  xclip zed zstd

    android-tools
    brave
    eza
    gawk
    goose-cli
    less
    libqalculate
    pandoc
    ripgrep
    rsgain
    texliveFull
    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
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
    ".abcde.conf".source = ../artifacts/abcde.conf;
  };

  # Environment variables
  #
  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };
}
