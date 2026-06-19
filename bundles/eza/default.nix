{
  pkgs,
  config,
  ...
}: {
  programs.eza = {
    enable = true;

    package =
      if pkgs.stdenv.isDarwin
      then pkgs.eza
      else null;

    colors = "auto";
    git = true;
    icons =
      if "${config.home.username}" == "droid"
      then "never" # TODO: Change to "auto" once the Android Terminal supports custom fonts
      else "auto";

    extraOptions = [
      "-F"
      "-g"
      "--group-directories-first"
    ];
  };
}
