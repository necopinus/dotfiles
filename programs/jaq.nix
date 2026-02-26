{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    jaq
  ];

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/jaq.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias jq="${pkgs.jaq}/bin/jaq"
      alias yq="${pkgs.jaq}/bin/jaq"
    '';
  };
  xdg.configFile."zsh/rc.d/jaq.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias jq="${pkgs.jaq}/bin/jaq"
      alias yq="${pkgs.jaq}/bin/jaq"
    '';
  };
  xdg.configFile."fish/rc.d/jaq.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias jq "${pkgs.jaq}/bin/jaq"
      alias yq "${pkgs.jaq}/bin/jaq"
    '';
  };
}
