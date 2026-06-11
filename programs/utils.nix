{
  pkgs,
  config,
  ...
}: let
  localPkgs = {
    editor = pkgs.callPackage ../pkgs/editor.nix {};
    nvim = pkgs.callPackage ../pkgs/nvim.nix {};
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
    shutdown = pkgs.callPackage ../pkgs/shutdown.nix {};
    sudo = pkgs.callPackage ../pkgs/sudo.nix {};
    vi = pkgs.callPackage ../pkgs/vi.nix {};
    vim = pkgs.callPackage ../pkgs/vim.nix {};
  };
in {
  home.packages = with pkgs; [
    #### Essential utilities ####
    curl
    dnsutils
    gawk
    gnugrep
    gnutar # Switch to `uutils-tar` when stable
    poppler-utils
    rsync
    unzip
    uutils-coreutils-noprefix
    uutils-diffutils
    uutils-findutils
    #uutils-hostname # Unmask when stable
    #uutils-login # Unmask when stable
    uutils-sed
    which
    xcp
    xz # Used by gnutar
    zip

    #### Convenience wrappers (see above) ####
    localPkgs.editor
    localPkgs.nvim
    localPkgs.pbcopy
    localPkgs.pbpaste
    localPkgs.shutdown
    localPkgs.sudo
    localPkgs.vi
    localPkgs.vim
  ];

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/utils.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias cp="${pkgs.xcp}/bin/xcp -r"
      alias mv="${pkgs.uutils-coreutils-noprefix}/bin/mv -v"
      alias rm="${pkgs.uutils-coreutils-noprefix}/bin/rm -v"
    '';
  };
  xdg.configFile."zsh/rc.d/utils.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias cp="${pkgs.xcp}/bin/xcp -r"
      alias mv="${pkgs.uutils-coreutils-noprefix}/bin/mv -v"
      alias rm="${pkgs.uutils-coreutils-noprefix}/bin/rm -v"
    '';
  };
  xdg.configFile."fish/rc.d/utils.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias cp "${pkgs.xcp}/bin/xcp -r"
      alias mv "${pkgs.uutils-coreutils-noprefix}/bin/mv -v"
      alias rm "${pkgs.uutils-coreutils-noprefix}/bin/rm -v"
    '';
  };
}
