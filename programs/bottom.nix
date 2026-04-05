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
  xdg.configFile."bash/rc.d/bottom.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias btm="${config.programs.bottom.package}/bin/btm --theme gruvbox"
      alias htop="${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
      alias top="${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
    '';
  };
  xdg.configFile."zsh/rc.d/bottom.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias btm="${config.programs.bottom.package}/bin/btm --theme gruvbox"
      alias htop="${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
      alias top="${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
    '';
  };
  xdg.configFile."fish/rc.d/bottom.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias btm "${config.programs.bottom.package}/bin/btm --theme gruvbox"
      alias htop "${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
      alias top "${config.programs.bottom.package}/bin/btm -b --theme gruvbox"
    '';
  };
}
