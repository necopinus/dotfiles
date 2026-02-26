{
  config,
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;

    themes = {
      gruvbox-material-light-hard = {
        src = ../artifacts/config/bat/themes;
        file = "gruvbox-material-light-hard.tmTheme";
      };
    };
  };

  home.sessionVariables.BAT_THEME = "ansi"; # TODO: Change to "gruvbox-light" once the Android Terminal supports custom themes

  # Colorize man pages with bat
  #
  # https://github.com/sharkdp/bat/issues/1433#issuecomment-3298530339
  #
  # Also, some convenience aliases
  #
  xdg.configFile."bash/rc.d/bat.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      export MANPAGER="$(${pkgs.which}/bin/which sh) -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias less="${config.programs.bat.package}/bin/bat bat"
      alias more="${config.programs.bat.package}/bin/bat bat"
    '';
  };
  xdg.configFile."zsh/rc.d/bat.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      export MANPAGER="$(${pkgs.which}/bin/which sh) -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias less="${config.programs.bat.package}/bin/bat bat"
      alias more="${config.programs.bat.package}/bin/bat bat"
    '';
  };
  xdg.configFile."fish/rc.d/bat.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      set -gx MANPAGER "$(${pkgs.which}/bin/which sh) -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | ${config.programs.bat.package}/bin/bat -p -lman'"

      alias cat "${config.programs.bat.package}/bin/bat -pp"
      alias less "${config.programs.bat.package}/bin/bat"
      alias more "${config.programs.bat.package}/bin/bat"
    '';
  };
}
