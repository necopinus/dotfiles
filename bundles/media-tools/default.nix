{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      libgourou # Broken on macOS as of 2026-06-09
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      xld # No longer available through Homebrew as of 2026-09-01

      #### Installed at the system level on Linux ####
      ffmpeg
      flac
      imagemagick
      libjpeg
      optipng
      pdftk
      poppler-utils
      rsgain
    ];

  # We don't use the system version of yt-dlp on Linux, as having an
  # up-to-date package is *really* important!
  #
  programs.yt-dlp.enable = true;
}
