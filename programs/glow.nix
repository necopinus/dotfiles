{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    glow
  ];

  # Themes
  #
  xdg.configFile = {
    "glow/styles/gruvbox-light.json".source = ../artifacts/config/glow/styles/gruvbox-light.json;
    "glow/styles/gruvbox-material-light-hard.json".source = ../artifacts/config/glow/styles/gruvbox-material-light-hard.json;
  };

  # Convenience aliases
  #
  # TODO: Change this to
  #
  #   -s $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json
  #
  # once the Android Terminal supports custom themes
  #
  xdg.configFile."bash/rc.d/glow.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias glow="${pkgs.glow}/bin/glow -s dark"
    '';
  };
  xdg.configFile."zsh/rc.d/glow.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias glow="${pkgs.glow}/bin/glow -s dark"
    '';
  };
  xdg.configFile."fish/rc.d/glow.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias glow "${pkgs.glow}/bin/glow -s dark"
    '';
  };
}
