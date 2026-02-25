{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    chafa
  ];

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/chafa.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias imgcat="${pkgs.chafa}/bin/chafa"
    '';
  };
  xdg.configFile."zsh/rc.d/chafa.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias imgcat="${pkgs.chafa}/bin/chafa"
    '';
  };
  xdg.configFile."fish/rc.d/chafa.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias imgcat "${pkgs.chafa}/bin/chafa"
    '';
  };
}
