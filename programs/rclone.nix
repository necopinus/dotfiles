{...}: {
  programs.rclone.enable = true;

  xdg.configFile = {
    "rclone/exclude".source = ../artifacts/config/rclone/exclude;
    "rclone/rclone.conf".source = ../artifacts/config/empty.file;
  };
}
