{
  pkgs,
  lib,
  config,
  ...
}: let
  nodePkg =
    if config.programs.npm.package != null
    then config.programs.npm.package
    else pkgs.nodejs;
in {
  home.packages = with pkgs;
    lib.optionals pkgs.stdenv.isLinux [
      libgourou # Broken on macOS as of 2026-06-09
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      xld # No longer available through Homebrew as of 2026-09-01

      #### Installed at the system level on Linux ####
      exiv2
      ffmpeg
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
  programs.yt-dlp = {
    enable = true;

    # The `deno` dependency for `yt-dlp` frequently breaks on
    # aarch64-linux, so we swap it out for `nodejs` instead
    #
    # https://www.reddit.com/r/NixOS/comments/1t13tp1/comment/ojdyk01/
    #
    package =
      if (pkgs.stdenv.hostPlatform.system == "aarch64-linux")
      then
        pkgs.yt-dlp.overrideAttrs (previousAttrs: {
          postPatch = ''
            substituteInPlace yt_dlp/version.py \
              --replace-fail "UPDATE_HINT = None" 'UPDATE_HINT = "Nixpkgs/NixOS likely already contain an updated version.\n       To get it run nix-channel --update or nix flake update in your config directory."'
            substituteInPlace yt_dlp/utils/_jsruntime.py \
              --replace-fail "path = _determine_runtime_path(self._path, '${nodePkg.meta.mainProgram}')" "path = '${lib.getExe nodePkg}'"
          '';
        })
      else pkgs.yt-dlp;
  };
}
