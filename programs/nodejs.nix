{pkgs, ...}: {
  programs.npm.enable = true;

  home.packages = with pkgs; [
    pnpm
  ];
}
