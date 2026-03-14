{pkgs, ...}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
  };
in {
  programs.zellij = {
    enable = true;

    settings = {
      theme = "ansi";
      default_shell = "${pkgs.fish}/bin/fish";

      copy_command = "${localPkgs.pbcopy}/bin/pbcopy";
    };

    # Do not enable the fish shell integration, as we use Zellij to
    # start fish in the first place
    #
    # FIXME: Why do I explicitly have to set the bash and zsh
    # integrations here, but not for other programs?
    #
    enableBashIntegration = true;
    enableFishIntegration = false;
    enableZshIntegration = true;

    # We live in Zellij now, the parent shell is but a memory
    #
    exitShellOnExit = true;
  };
}
