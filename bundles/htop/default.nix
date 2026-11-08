{
  pkgs,
  config,
  ...
}: {
  programs.htop = {
    enable = true;

    settings =
      {
        hide_kernel_threads = 0;
        highlight_base_name = 1;
      }
      // (
        if pkgs.stdenv.hostPlatform.isDarwin
        then
          (with config.lib.htop;
            leftMeters [
              (bar "LeftCPUs")
              (bar "MemorySwap")
              (text "DiskIO")
              (text "NetworkIO")
            ])
          // (with config.lib.htop;
            rightMeters [
              (bar "RightCPUs")
              (bar "GPU")
              (text "Tasks")
              (text "Uptime")
            ])
        else
          (with config.lib.htop;
            leftMeters [
              (bar "LeftCPUs")
              (bar "Memory")
              (text "DiskIO")
              (text "NetworkIO")
            ])
          // (with config.lib.htop;
            rightMeters [
              (bar "RightCPUs")
              (bar "Swap")
              (text "Tasks")
              (text "Uptime")
            ])
      );
  };

  xdg.configFile."bash/rc.d/htop.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias top="${config.programs.htop.package}/bin/htop"
    '';
  };
  xdg.configFile."zsh/rc.d/htop.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias top="${config.programs.htop.package}/bin/htop"
    '';
  };
  xdg.configFile."fish/rc.d/htop.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias top "${config.programs.htop.package}/bin/htop"
    '';
  };
}
