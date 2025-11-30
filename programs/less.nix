{...}: {
  programs.less = {
    enable = true;
    options = {
      # Hyperlink support in LESS
      #
      # You'd *think* you'd want to include `use-color` here too, but
      # doing so seems to disrupt *existing* colorization in applications
      # like `man`
      #
      RAW-CONTROL-CHARS = true;
    };
  };
}
