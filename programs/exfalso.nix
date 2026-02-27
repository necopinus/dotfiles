{pkgs, ...}: {
  home.packages = with pkgs; [
    quodlibet-full
  ];

  # Hide Quod Libet desktop entry, since we really only care about Ex
  # Falso
  #
  xdg.desktopEntries."io.github.quodLibet" = {
    noDisplay = true;
    settings = {
      Hidden = true;
    };
  };
}
