{
  config,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;

    settings = {
      theme = "ansi";
      default_shell = "${config.xdg.configHome}/zellij/.fish-wrapper";
    };

    # Do not enable any integrations, as we only want Zellij for
    # managing SSH connections
    #
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  # Wrapper to launch fish as a login shell, since
  # settings.default_shell can only be a path
  #
  xdg.configFile."zellij/.fish-wrapper" = {
    executable = true;
    text = ''
      #!${pkgs.bashInteractive}/bin/sh
      exec ${pkgs.fish}/bin/fish --interactive --login
    '';
  };
}
