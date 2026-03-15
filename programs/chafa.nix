{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    chafa
    uutils-coreutils-noprefix
  ];

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/chafa.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias chafa="${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
      alias imgcat="${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
    '';
  };
  xdg.configFile."zsh/rc.d/chafa.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias chafa="${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
      alias imgcat="${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
    '';
  };
  xdg.configFile."fish/rc.d/chafa.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias chafa "${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
      alias imgcat "${pkgs.uutils-coreutils-noprefix}/bin/env TERM=xterm-kitty ${pkgs.chafa}/bin/chafa -f symbols"
    '';
  };
}
