{pkgs, ...}: let
  localPkgs = {
    vault-sync = pkgs.callPackage ../pkgs/vault-sync.nix {};
  };
in {
  programs.rclone.enable = true;

  xdg.configFile = {
    "rclone/exclude".source = ../artifacts/config/rclone/exclude;
    "rclone/rclone.conf".text = "";
  };

  # Laptop external backup script
  #
  home.packages = [localPkgs.vault-sync];
}
