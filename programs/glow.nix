{pkgs, ...}: {
  home.packages = with pkgs; [
    glow
  ];

  xdg.configFile = {
    "glow/styles/gruvbox-light.json".source = ../artifacts/config/glow/styles/gruvbox-light.json;
    "glow/styles/gruvbox-material-light-hard.json".source = ../artifacts/config/glow/styles/gruvbox-material-light-hard.json;
  };
}
