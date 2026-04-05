{
  config,
  pkgs,
  ...
}: {
  programs.bat.enable = true;

  home.sessionVariables.BAT_THEME = "gruvbox-dark";

  # Colorize man pages with bat
  #
  # https://github.com/sharkdp/bat/issues/1433#issuecomment-3298530339
  #
  # Also, some convenience aliases
  #
  xdg.configFile."bash/rc.d/bat.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      export MANPAGER="${pkgs.bashInteractive}/bin/sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias less="${config.programs.bat.package}/bin/bat bat"
      alias more="${config.programs.bat.package}/bin/bat bat"
    '';
  };
  xdg.configFile."zsh/rc.d/bat.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      export MANPAGER="${pkgs.bashInteractive}/bin/sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias less="${config.programs.bat.package}/bin/bat bat"
      alias more="${config.programs.bat.package}/bin/bat bat"
    '';
  };
  xdg.configFile."fish/rc.d/bat.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      set -gx MANPAGER "${pkgs.bashInteractive}/bin/sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat "${config.programs.bat.package}/bin/bat -pp"
      alias less "${config.programs.bat.package}/bin/bat"
      alias more "${config.programs.bat.package}/bin/bat"
    '';
  };
}
