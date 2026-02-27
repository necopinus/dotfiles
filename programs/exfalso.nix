{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    quodlibet-full
  ];

  # Hide Quod Libet desktop entry, since we really only care about Ex
  # Falso
  #
  xdg.desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    "io.github.quodlibet.QuodLibet" = {
      name = "Quod Libet";
      noDisplay = true;
      settings = {
        Hidden = "true";
      };
    };
  };
}
