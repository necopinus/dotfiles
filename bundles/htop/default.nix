{
  pkgs,
  config,
  ...
}: let
  localPkgs = {
    top = pkgs.callPackage ./pkgs/top.nix {};
  };
in {
  programs.htop = {
    enable = true;

    settings =
      {
        hide_kernel_threads = 0;
        highlight_base_name = 1;
      }
      // (
        if pkgs.stdenv.isDarwin
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

  # Convenience wrapper
  #
  home.packages = [
    localPkgs.top
  ];
}
