{...}: {
  programs.bat = {
    enable = true;
    themes = {
      gruvbox-material-light-hard = {
        src = ../artifacts/config/bat/themes;
        file = "gruvbox-material-light-hard.tmTheme";
      };
    };
  };
}
