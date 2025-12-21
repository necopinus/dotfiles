{pkgs, ...}: {
  programs.jq = {
    enable = true;
    package = pkgs.jaq;
  };
}
