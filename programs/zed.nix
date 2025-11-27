{pkgs, ...}: let
  # Hack so that Zed picks up extraPackages on macOS; refer to the more
  # detailed note at the end of this file
  #
  zedExtraPackages = with pkgs; [
    #### LSPs ####
    #bash-language-server
    #fish-lsp
    #lua-language-server
    #markdown-oxide
    #marksman
    nil
    nixd
    #python3Packages.python-lsp-server
    #ruff
    #solc
    #superhtml
    #systemd-lsp # Set in flake.nix overlay
    #taplo
    #tombi
    #ty
    #typescript-language-server
    #vscode-langservers-extracted
    #yaml-language-server

    #### Formatters ####
    alejandra
    #prettier
    #shellcheck
    #shfmt
  ];
in {
  programs.zed-editor = {
    enable = true;

    extraPackages = zedExtraPackages;

    extensions = [
      "html"
      "nix"
      #
      #######################################
      # Need to finish adding extensions... #
      #######################################
      #
    ];

    userSettings = {
      auto_indent_on_paste = true;
      format_on_save = "on";
      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_size = 12;
      ui_font_size = 14;
      features = {
        edit_prediction_provider = "none";
      };

      languages = {
        Nix = {
          formatter = {
            external = {
              command = "alejandra";
              arguments = [
                "--quiet"
                "--"
              ];
            };
          };
        };
      };

      theme = {
        mode = "light";
        light = "Gruvbox Light";
        dark = "Gruvbox Dark";
      };
      icon_theme = {
        mode = "light";
        light = "Zed (Default)";
        dark = "Zed (Default)";
      };
    };
  };

  # Zed doesn't seem to see the programs installed using
  # programs.zed-editor.extraPackages on macOS, so we use this hack to
  # expose them explicitly in ~/.nix-profile/bin
  #
  home.packages = pkgs.lib.optionals pkgs.stdenv.isDarwin zedExtraPackages;
}
