{
  pkgs,
  ...
}: {
  # Manually install Obsidian rather than using programs.obsidian.enable
  # = true in order to work around vaults not being remembered. See:
  #
  #   https://github.com/nix-community/home-manager/issues/7406
  # 
  home.packages = with pkgs; [
    obsidian
  ];

  # Obsidian won't work with the Android VM's virtual GPU
  #
  xdg.dataFile."applications/obsidian.desktop".source = ../artifacts/local/share/applications/obsidian.desktop;
  programs.fish.functions.obsidian = ''
    set OBSIDIAN_EXEC $(which obsidian)
    $OBSIDIAN_EXEC --disable-gpu $argv
  '';
}
