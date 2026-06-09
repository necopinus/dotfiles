{pkgs, ...}: let
  localPkgs = {
    jq = pkgs.callPackage ../pkgs/jq.nix {};
    yq = pkgs.callPackage ../pkgs/yq.nix {};
  };
in {
  home.packages = with pkgs; [
    jaq
    localPkgs.jq
    localPkgs.yq
  ];
}
