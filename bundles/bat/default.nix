{
  config,
  pkgs,
  ...
}: let
  localPkgs = {
    less = pkgs.callPackage ./pkgs/less.nix {};
  };
in {
  programs.bat.enable = true;

  # Set theme
  #
  home.sessionVariables.BAT_THEME = "gruvbox-light";

  # Colorize man pages with bat
  #
  # https://github.com/sharkdp/bat/issues/1433#issuecomment-3298530339
  #
  home.sessionVariables.MANPAGER = "sh -c 'sed -u -e \\\"s/\\\\x1B\\[[0-9;]*m//g;s/.\\\\x08//g\\\" | ${config.programs.bat.package}/bin/bat -p -lman'";

  # Make sure that Nerd Fonts display in less
  #
  # https://github.com/ryanoasis/nerd-fonts/wiki/FAQ-and-Troubleshooting#less-settings
  #
  home.sessionVariables.LESSUTFCHARDEF =
    if "${config.home.username}" == "droid"
    then null
    else "e000-f8ff:p,f0001-fffff:p";

  # Convenience wrappers and aliases
  #
  home.packages = [
    localPkgs.less
  ];

  xdg.configFile."bash/rc.d/bat.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias more="${config.programs.bat.package}/bin/bat"
    '';
  };
  xdg.configFile."zsh/rc.d/bat.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias cat="${config.programs.bat.package}/bin/bat -pp"
      alias more="${config.programs.bat.package}/bin/bat"
    '';
  };
  xdg.configFile."fish/rc.d/bat.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias cat "${config.programs.bat.package}/bin/bat -pp"
      alias more ${config.programs.bat.package}/bin/bat
    '';
  };
}
