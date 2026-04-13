{pkgs, ...}: {
  # Manually install Obsidian rather than using programs.obsidian.enable
  # = true in order to work around vaults not being remembered. See:
  #
  #   https://github.com/nix-community/home-manager/issues/7406
  #
  home.packages = with pkgs; [
    obsidian
    xdg-utils
  ];

  # Obsidian won't work with the Android VM's virtual GPU, and the
  # Android VM also doesn't support user namespaces (needed for the
  # Electron sandbox to work)
  #
  # FIXME: Check if this is still necessary after each Android release!
  #
  xdg = {
    desktopEntries = {
      "obsidian" = {
        categories = ["Office"];
        comment = "Knowledge base";
        exec = "${pkgs.obsidian}/bin/obsidian --disable-gpu --no-sandbox %u";
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
        alias obsidian="${pkgs.obsidian}/bin/obsidian --disable-gpu --no-sandbox"
      '';
      "fish/rc.d/obsidian.fish".text = ''
        alias obsidian "${pkgs.obsidian}/bin/obsidian --disable-gpu --no-sandbox"
      '';
      "zsh/rc.d/obsidian.sh".text = ''
        alias obsidian="${pkgs.obsidian}/bin/obsidian --disable-gpu --no-sandbox"
      '';
    };
  };
}
