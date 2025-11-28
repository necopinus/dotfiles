{pkgs, ...}: let
  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix {};
    update-system = pkgs.callPackage ../pkgs/update-system.nix {};
  };
in {
  imports = [
    ../programs/bat.nix
    ../programs/bottom.nix
    ../programs/delta.nix # Requires bat.nix
    ../programs/git.nix
    ../programs/glow.nix
    ../programs/helix.nix
    ../programs/rclone.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/zed.nix
  ];

  home.packages = with pkgs; [
    # Remove:
    #   ~/.abcde.conf
    #   ~/.default-gems
    #   ~/.default-npm-packages
    #   ~/.default-python-packages
    #   ~/.procs.toml
    #   ~/.ssh/authorized_keys
    #   ~/.ssh/config
    #   ~/bin
    #   ~/cache/env
    #   ~/config/bat
    #   ~/config/bottom
    #   ~/config/git
    #   ~/config/glow
    #   ~/config/helix
    #   ~/config/mise
    #   ~/config/moxide
    #   ~/config/qobuz-dl
    #   ~/config/rclone
    #   ~/config/starship
    #   ~/config/zed
    #   ~/local/lib
    #   ~/local/state/mise
    #   ~/local/share/applications
    #   ~/local/share/fonts
    #   ~/local/share/icons
    #   ~/local/share/mise
    #   /etc/apt/sources.list.d/brave-browser.sources
    #   /usr/share/keyrings/brave-browser-archive-keyring.gpg
    #
    # Modify:
    #   ~/.bashrc (remove find/grep/du/df aliases)
    #   ~/.profile
    #   ~/config/fish/config.fish (remove find/grep/du/df aliases)
    #   ~/.zshrc (remove find/grep/du/df aliases)
    #
    # Commands:
    #   sudo apt purge --autoremove --purge \
    #            android-sdk-platform-tools apt-utils brave-browser \
    #            build-essential calibre eject file fonts-noto \
    #            gnome-keyring gnupg handbrake podman procps uuid-runtime \
    #            wl-clipboard xdg-utils xdg-user-dirs
    #
    #   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    #   But I still need gpg! If it actually gets removed, then I'll need
    #   to re-add it using nix. Which, honestly, would be easier than
    #   dealing with Debian's packaging anyway...
    #
    #   Maybe something like this, but both for gpg-agent and ssh-agent?
    #
    #   https://unix.stackexchange.com/a/665536
    #   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    #
    #   brew analytics on
    #
    #   brew uninstall libqalculate openvpn xsel yq yt-dlp
    #
    #   brew uninstall abcde android-platform-tools bat block-goose-cli \
    #                  bottom brave-browser cd-discid curl delve \
    #                  diff-so-fancy discord dos2unix duf dust eza fd \
    #                  ffmpeg fzf font-jetbrains-mono-nerd-font gawk ghc \
    #                  ghostscript git git-delta glow gopls \
    #                  haskell-language-server helix imagemagick jdtls \
    #                  jpeg-turbo jq jq-lsp less lua-language-server \
    #                  libyaml markdown-oxide mise normalize openssh \
    #                  optipng pandoc pngpaste poppler procs proton-mail \
    #                  pstree rclone ripgrep rsgain rsync ruff rust \
    #                  rust-analyzer shellcheck shfmt slack solidity \
    #                  sqlite starship swift-format texlab tinymist \
    #                  uutils-coreutils uutils-diffutils uutils-findutils \
    #                  xclip xz yamlresume zed zstd

    android-tools
    brave
    curlFull
    eza
    gawk
    goose-cli
    imagemagick
    jq
    less
    libjpeg
    libqalculate
    msgpack-tools
    optipng
    pandoc
    poppler-utils
    ripgrep
    rsgain
    rsync
    sqlite
    texliveFull
    unzip
    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
    xz
    yq
    yt-dlp
    zip

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  # Additional dotfiles
  #
  #home.file = {
  #  "config/marksman/config.toml".source = ../artifacts/config/marksman/config.toml;
  #};

  # Environment variables
  #
  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };
}
