{pkgs, ...}: {
  home.packages = with pkgs; [
    glow
  ];

  home.file = {
    "config/glow/styles/gruvbox-light.json".source = ../artifacts/config/glow/styles/gruvbox-light.json;
    "config/glow/styles/gruvbox-material-light-hard.json".source = ../artifacts/config/glow/styles/gruvbox-material-light-hard.json;
  };
}
