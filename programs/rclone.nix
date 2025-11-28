{...}: {
  programs.rclone.enable = true;

  home.file = {
    "config/rclone/exclude".source = ../artifacts/config/rclone/exclude;
    "config/rclone/rclone.conf".source = ../artifacts/config/empty.file;
  };
}
