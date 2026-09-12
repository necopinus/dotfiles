{pkgs, ...}: {
  programs.eza = {
    enable = true;

    package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.eza
      else null;

    colors = "auto";
    git = true;
    icons = "auto";

    extraOptions = [
      "-F"
      "-g"
      "--group-directories-first"
    ];
  };
}
