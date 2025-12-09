{...}: {
  programs.obsidian.enable = true;

  # Obsidian won't work with the Android VM's virtual GPU
  #
  xdg.dataFile."applications/obsidian.desktop".source = ../artifacts/local/share/applications/obsidian.desktop;
  programs.fish.functions.obsidian = ''
    set OBSIDIAN_EXEC $(which obsidian)
    $OBSIDIAN_EXEC --disable-gpu $argv
  '';
}
