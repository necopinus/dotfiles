{
  config,
  pkgs,
  ...
}: let
  localPkgs = {
    backup-home = pkgs.callPackage ../pkgs/backup-home.nix {};
    update-system = pkgs.callPackage ../pkgs/update-system.nix {};
  };
in {
  imports = [
    ../programs/bash.nix
    ../programs/bat.nix
    ../programs/bottom.nix
    ../programs/delta.nix # Requires bat.nix
    ../programs/dircolors.nix
    ../programs/direnv.nix
    ../programs/fish.nix
    ../programs/git.nix
    ../programs/glow.nix
    ../programs/helix.nix
    ../programs/less.nix
    ../programs/rclone.nix
    ../programs/ssh.nix
    ../programs/starship.nix
    ../programs/wezterm.nix # Requires fish.nix
    ../programs/zed.nix
  ];

  programs.jq.enable = true;
  programs.pandoc.enable = true;
  programs.ripgrep.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    # Remove:
    #   ~/.abcde.conf
    #   ~/.bash_profile
    #   ~/.bashrc
    #   ~/.default-gems
    #   ~/.default-npm-packages
    #   ~/.default-python-packages
    #   ~/.gnupg/gpg-agent.conf
    #   ~/.procs.toml
    #   ~/.profile
    #   ~/.ssh/authorized_keys
    #   ~/.ssh/config
    #   ~/.zshenv
    #   ~/.zshrc
    #   ~/bin
    #   ~/cache/env
    #   ~/config/autostart
    #   ~/config/bat
    #   ~/config/bottom
    #   ~/config/environment.d
    #   ~/config/fish
    #   ~/config/git
    #   ~/config/glow
    #   ~/config/helix
    #   ~/config/mimeapps.list
    #   ~/config/mise
    #   ~/config/moxide
    #   ~/config/qobuz-dl
    #   ~/config/rclone
    #   ~/config/starship
    #   ~/config/user-dirs.dirs
    #   ~/config/xdg-terminals.list
    #   ~/config/xfce4
    #   ~/config/zed
    #   ~/local/bin
    #   ~/local/lib
    #   ~/local/state/mise
    #   ~/local/share/applications
    #   ~/local/share/fonts
    #   ~/local/share/icons
    #   ~/local/share/mise
    #   ~/local/share/xfce4
    #   /etc/apt/sources.list.d/brave-browser.sources
    #   /etc/apt/sources.list.d/wezterm.list
    #   /usr/share/keyrings/brave-browser-archive-keyring.gpg
    #   /usr/share/keyrings/wezterm-fury.gpg
    #
    # Commands:
    #   sudo apt purge --autoremove --purge \
    #            android-sdk-platform-tools apt-utils brave-browser \
    #            build-essential calibre eject file fonts-noto \
    #            gnome-keyring gnupg handbrake podman procps uuid-runtime \
    #            wezterm wl-clipboard xdg-utils xdg-user-dirs
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
    #                  ffmpeg fish font-jetbrains-mono-nerd-font fzf gawk \
    #                  ghc ghostscript git git-delta glow gnupg gopls \
    #                  haskell-language-server helix imagemagick jdtls \
    #                  jpeg-turbo jq jq-lsp less lua-language-server \
    #                  libyaml markdown-oxide mise normalize openssh \
    #                  optipng pandoc pinentry-mac pngpaste poppler procs \
    #                  proton-mail pstree rclone ripgrep rsgain rsync \
    #                  ruff rust rust-analyzer shellcheck shfmt slack \
    #                  solidity sqlite starship swift-format texlab \
    #                  tinymist uutils-coreutils uutils-diffutils \
    #                  uutils-findutils wezterm xclip xz yamlresume zed \
    #                  zoxide zstd

    #
    # 1. Finish configuring macOS
    # 2. Debug Android VM
    #

    android-tools
    brave
    curlFull
    eza # Don't use programs.eza.enable because aliases differ between fish and bash/zsh
    gawk
    goose-cli
    imagemagick
    libjpeg
    libqalculate
    msgpack-tools
    optipng
    poppler-utils
    rsgain
    rsync
    sqlite
    texliveFull # Can't figure out how to get programs.texlive to work...
    unzip
    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
    xz
    yq
    zip

    #### Local packages (see above) ####
    localPkgs.backup-home
    localPkgs.update-system
  ];

  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/cache";
    configHome = "${config.home.homeDirectory}/config";
    dataHome = "${config.home.homeDirectory}/local/share";
    stateHome = "${config.home.homeDirectory}/local/state";
  };

  # Environment variables
  #
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
