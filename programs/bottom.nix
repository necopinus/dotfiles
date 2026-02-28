{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.bottom.enable = true;

  # Hide desktop entry
  #
  xdg.desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    "bottom" = {
      name = "bottom";
      noDisplay = true;
      settings = {
        Hidden = "true";
      };
    };
  };

  # Convenience aliases
  #
  # TODO: Change this to "--theme gruvbox-light" once the Android
  # Terminal supports custom themes
  #
  xdg.configFile."bash/rc.d/bottom.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias btm="${config.programs.bottom.package}/bin/btm --theme default"
      alias htop="${config.programs.bottom.package}/bin/btm --basic --theme default"
      alias top="${config.programs.bottom.package}/bin/btm --basic --theme default"
    '';
  };
  xdg.configFile."zsh/rc.d/bottom.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias btm="${config.programs.bottom.package}/bin/btm --theme default"
      alias htop="${config.programs.bottom.package}/bin/btm --basic --theme default"
      alias top="${config.programs.bottom.package}/bin/btm --basic --theme default"
    '';
  };
  xdg.configFile."fish/rc.d/bottom.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias btm "${config.programs.bottom.package}/bin/btm --theme default"
      alias htop "${config.programs.bottom.package}/bin/btm --basic --theme default"
      alias top "${config.programs.bottom.package}/bin/btm --basic --theme default"
    '';
  };
}
