{config, ...}: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      line-numbers = true;
      navigate = true;
      side-by-side = true;

      # Themes; they're just defined here, but then explicitly enabled
      # using the DELTA_FEATURES environment variable (below)
      #
      ansi-dark = {
        dark = true;
        syntax-theme = "base16";
      };
      ansi-light = {
        light = true;
        syntax-theme = "ansi";
      };
      gruvbox-light = {
        light = true;
        syntax-theme = "gruvbox-light"; # Requires bat.nix
        blame-palette = "#fbf1c7 #f2e5bc #ebdbb2";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
        line-numbers-zero-style = "normal";
        minus-emph-style = "syntax #f1d194";
        minus-empty-line-marker-style = "normal #f5e1ae";
        minus-non-emph-style = "syntax #f5e1ae";
        minus-style = "syntax #f5e1ae";
        plus-emph-style = "syntax #e8dea8";
        plus-empty-line-marker-style = "normal #f2e7b8";
        plus-non-emph-style = "syntax #f2e7b8";
        plus-style = "syntax #f2e7b8";
      };
      gruvbox-material-light-hard = {
        light = true;
        syntax-theme = "gruvbox-material-light-hard"; # Requires bat.nix
        blame-palette = "#fbf1c7 #f4e8be #f2e5bc";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
        line-numbers-zero-style = "normal";
        minus-emph-style = "syntax #f3d0ad";
        minus-empty-line-marker-style = "normal #f7e0bb";
        minus-non-emph-style = "syntax #f7e0bb";
        minus-style = "syntax #f7e0bb";
        plus-emph-style = "syntax #ddd8a8";
        plus-empty-line-marker-style = "normal #ede4b7";
        plus-non-emph-style = "syntax #ede4b7";
        plus-style = "syntax #ede4b7";
      };
    };
  };

  home.sessionVariables.DELTA_FEATURES = "+ansi-dark"; # TODO: Change to "+gruvbox-light" once the Android Terminal supports custom themes

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/delta.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias diff="${config.programs.delta.package}/bin/delta"
    '';
  };
  xdg.configFile."zsh/rc.d/delta.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias diff="${config.programs.delta.package}/bin/delta"
    '';
  };
  xdg.configFile."fish/rc.d/delta.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias diff "${config.programs.delta.package}/bin/delta"
    '';
  };
}
