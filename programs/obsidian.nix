{
  pkgs,
  lib,
  ...
}: {
  # Manually install Obsidian rather than using programs.obsidian.enable
  # = true in order to work around vaults not being remembered. See:
  #
  #   https://github.com/nix-community/home-manager/issues/7406
  #
  home.packages = with pkgs; [
    obsidian
    xdg-utils
  ];

  # Obsidian won't work with the Android VM's virtual GPU
  #
  xdg = {
    desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      "obsidian" = {
        categories = ["Office"];
        comment = "Knowledge base";
        exec = "${pkgs.obsidian}/bin/obsidian --disable-gpu %u";
        icon = "obsidian";
        mimeType = [
          "x-scheme-handler/obsidian"
        ];
        name = "Obsidian";
        type = "Application";
      };
    };

    configFile = {
      "bash/rc.d/obsidian.sh".text = ''
        alias obsidian="${pkgs.obsidian}/bin/obsidian --disable-gpu"
      '';
      "fish/rc.d/obsidian.fish".text = ''
        alias obsidian "${pkgs.obsidian}/bin/obsidian --disable-gpu"
      '';
      "zsh/rc.d/obsidian.sh".text = ''
        alias obsidian="${pkgs.obsidian}/bin/obsidian --disable-gpu"
      '';
    };
  };
}
