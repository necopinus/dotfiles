{...}: {
  programs.eza = {
    enable = true;

    colors = "auto";
    git = true;
    icons = "never"; # TODO: Change to "auto" once the Android Terminal supports custom fonts

    extraOptions = [
      "-F"
      "-g"
      "--group-directories-first"
    ];
  };
}
