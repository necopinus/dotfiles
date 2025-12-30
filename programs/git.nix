{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings = {
      user = {
        name = "Nathan Acks";
        email = "nathan.acks@cardboard-iguana.com";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
    };
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = true;
    };
  };
}
