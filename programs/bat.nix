{pkgs, ...}: {
  programs.bat = {
    enable = true;
    extraPackages = with pkgs; [
      bat-extras.core
      black
      clang-tools
      delta
      elixir
      entr
      fzf
      prettier
      ripgrep
      rustfmt
      shfmt
    ];
    themes = {
      gruvbox-material-light-hard = {
        src = ../artifacts/config/bat/themes;
        file = "gruvbox-material-light-hard.tmTheme";
      };
    };
  };
}
