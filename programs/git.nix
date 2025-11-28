{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    includes = [
      {
        path = "gpg.ini"; # Created per-system by init.sh
      }
    ];
    signing.signByDefault = true;
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
  };
}
