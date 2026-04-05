{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    glow
  ];

  xdg.configFile."glow/styles/gruvbox-light.json".source = ../artifacts/config/glow/styles/gruvbox.json;

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/glow.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias glow="${pkgs.glow}/bin/glow -s gruvbox"
    '';
  };
  xdg.configFile."zsh/rc.d/glow.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias glow="${pkgs.glow}/bin/glow -s gruvbox"
    '';
  };
  xdg.configFile."fish/rc.d/glow.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias glow "${pkgs.glow}/bin/glow -s gruvbox"
    '';
  };
}
