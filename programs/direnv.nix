{
  config,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      package = pkgs.nix-nix-direnv; # FIXME: Need to modify package to replace `>/dev/stderr` with `1>&2` in direnvrc
    };
    config = {
      whitelist = {
        prefix = ["${config.home.homeDirectory}/engagements"];
      };
    };
  };
}
