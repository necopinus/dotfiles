{
  lib,
  pkgs,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../utils/pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../utils/pkgs/pbpaste.nix {};
  };

  helperPkgs = with pkgs; [
    #### LSPs ####
    awk-language-server
    bash-language-server
    clang-tools
    dockerfile-language-server
    ember-language-server
    fish-lsp
    gopls
    haskellPackages.haskell-language-server
    jdt-language-server
    jq-lsp
    kotlin-language-server
    lua-language-server
    markdown-oxide
    nixd
    rubyPackages.solargraph
    ruff
    rust-analyzer
    solc
    systemd-lsp
    texlab
    tombi
    ty
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server

    #### Formatters ####
    alejandra
    bibtex-tidy
    prettier
    shellcheck
    shfmt
    swift-format

    #### Debuggers ####
    delve
    lldb
  ];
in {
  xdg.configFile."moxide/settings.toml".source = ./files/config/moxide/settings.toml;

  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = helperPkgs;

    # Helix inexplicably doesn't have out-of-the-box support for
    # auto-formatting .nix files
    #
    languages = {
      language = [
        {
          name = "nix";
          formatter = {command = "${pkgs.alejandra}/bin/alejandra";};
          auto-format = true;
        }
      ];
    };

    settings = {
      theme = "gruvbox_light_mod";

      editor = {
        cursorline = true;
        completion-replace = true;
        bufferline = "always";
        color-modes = true;
        trim-final-newlines = true;

        clipboard-provider.custom = {
          yank.command = "${localPkgs.pbpaste}/bin/pbpaste";
          paste.command = "${localPkgs.pbcopy}/bin/pbcopy";
          primary-yank.command = "${localPkgs.pbpaste}/bin/pbpaste";
          primary-paste.command = "${localPkgs.pbcopy}/bin/pbcopy";
        };

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        whitespace = {
          render = {
            space = "none";
            nbsp = "all";
            nnbsp = "all";
            tab = "all";
            newline = "none";
          };

          characters = {
            space = "·";
            nbsp = "␣";
            nnbsp = "⍽";
            tab = "»";
            newline = "⏎";
          };
        };

        indent-guides.render = true;
        soft-wrap.enable = true;
        smart-tab.enable = true;
      };

      keys.insert = {
        C-a = "goto_line_start";
        C-e = "goto_line_end_newline";
      };
    };

    themes = {
      gruvbox_dark_mod = {
        inherits = "gruvbox";

        # Slightly more muted colors
        #
        "ui.bufferline" = {
          fg = "fg1";
          bg = "bg2";
        };
        "ui.bufferline.active" = {
          fg = "fg0";
          bg = "bg0";
        };

        "ui.linenr.selected" = {fg = "fg4";};

        "ui.selection.primary" = {bg = "bg2";};
        "ui.selection" = {bg = "bg1";};

        # Replace (most) italics with bold
        #
        "attribute" = {
          fg = "aqua1";
          modifiers = ["bold"];
        };
        "type.enum.variant" = {modifiers = ["bold"];};
        "variable.builtin" = {
          fg = "orange1";
          modifiers = ["bold"];
        };
        "variable.parameter" = {
          fg = "blue1";
          modifiers = ["bold"];
        };
      };
      gruvbox_light_mod = {
        inherits = "gruvbox_dark_mod";

        palette = {
          bg0 = "#fbf1c7";
          bg0_s = "#f2e5bc";
          bg1 = "#ebdbb2";
          bg2 = "#d5c4a1";
          bg3 = "#bdae93";
          bg4 = "#a89984";

          fg0 = "#282828";
          fg1 = "#3c3836";
          fg2 = "#504945";
          fg3 = "#665c54";
          fg4 = "#7c6f64";

          gray = "#928374";

          red0 = "#cc241d";
          red1 = "#9d0006";
          green0 = "#98971a";
          green1 = "#79740e";
          yellow0 = "#d79921";
          yellow1 = "#b57614";
          blue0 = "#458588";
          blue1 = "#076678";
          purple0 = "#b16286";
          purple1 = "#8f3f71";
          aqua0 = "#689d6a";
          aqua1 = "#427b58";
          orange0 = "#d65d0e";
          orange1 = "#af3a03";
        };
      };
    };
  };

  # Hide desktop entry
  #
  xdg.desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    "Helix" = {
      name = "Helix";
      noDisplay = true;
      settings = {
        Hidden = "true";
      };
    };
  };

  # Make sure that theming is always enabled
  #
  home.sessionVariables.COLORTERM = "truecolor";
}
