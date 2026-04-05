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
      gruvbox-dark = {
        dark = true;
        syntax-theme = "gruvbox-dark"; # Requires bat.nix
      };
      gruvbox-light = {
        light = true;
        syntax-theme = "gruvbox-light"; # Requires bat.nix
      };
    };
  };

  home.sessionVariables.DELTA_FEATURES = "+gruvbox-dark";

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
