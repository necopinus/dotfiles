{pkgs, ...}: {
  programs.zellij = {
    enable = true;

    settings = {
      theme = "ansi";
      default_shell = "${pkgs.fish}/bin/fish -li";
    };

    # Do not enable any integrations, as we only want Zellij for
    # managing SSH connections
    #
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };
}
