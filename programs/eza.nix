{...}: {
  programs.eza = {
    enable = true;

    colors = "auto";
    git = true;
    icons = "never"; # TODO: Change to "auto" once the Android Terminal supports custom fonts

    extraOptions = [
      "--classify=auto"
      "--group-directories-first"
      "--group"
    ];
  };
}
