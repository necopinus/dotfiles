{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
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
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      util-linux # `uutils-util-linux` is not supported on macOS
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      util-linux # Switch to `uutils-util-linux` when stable
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
  xdg.configFile."zsh/rc.d/utils.sh" = {
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
