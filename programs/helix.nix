{
  pkgs,
  lib,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
  };
in {
  xdg.configFile."moxide/settings.toml".source = ../artifacts/config/moxide/settings.toml;

  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs;
      [
        #### LSPs ####
        awk-language-server
        bash-language-server
        clang-tools
        dockerfile-language-server
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
        bibtex-tidy
        prettier
        shellcheck
        shfmt
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        #### Utilities ####
        localPkgs.pbcopy
        localPkgs.pbpaste
      ];

    settings = {
      theme = "gruvbox_light_mod";

      editor = {
        cursorline = true;
        completion-replace = true;
        bufferline = "always";
        color-modes = true;
        trim-final-newlines = true;

        clipboard-provider.custom = {
          yank.command = "pbpaste";
          paste.command = "pbcopy";
          primary-yank.command = "pbpaste";
          primary-paste.command = "pbcopy";
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
      gruvbox_light_mod = {
        inherits = "gruvbox_light";

        # Slightly lower contrast
        #
        "ui.cursorline" = {bg = "bg2";};
        "ui.bufferline" = {
          fg = "fg1";
          bg = "bg2";
        };
        "ui.bufferline.active" = {
          fg = "bg0";
          bg = "fg4";
        };
        "ui.bufferline.background" = {bg = "bg1";};

        "ui.linenr.selected" = {fg = "fg4";};

        "ui.selection" = {bg = "bg3";};
        "ui.selection.primary" = {bg = "bg2";};
        "ui.statusline" = {
          fg = "fg1";
          bg = "bg1";
        };
        "ui.statusline.inactive" = {
          fg = "fg4";
          bg = "bg1";
        };
        "ui.menu" = {
          fg = "fg1";
          bg = "bg1";
        };

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
          modifiers = [];
        };

        palette = {
          bg0_s = "#f2e5bc";
        };
      };
      gruvbox_material_light_hard = {
        # https://github.com/CptPotato/helix-themes

        "type" = "yellow";
        "constant" = "purple";
        "constant.numeric" = "purple";
        "constant.character.escape" = "orange";
        "string" = "green";
        "string.regexp" = "blue";
        "comment" = "grey0";
        "variable" = "fg0";
        "variable.builtin" = "blue";
        "variable.parameter" = "fg0";
        "variable.other.member" = "fg0";
        "label" = "aqua";
        "punctuation" = "grey2";
        "punctuation.delimiter" = "grey2";
        "punctuation.bracket" = "fg0";
        "keyword" = "red";
        "keyword.directive" = "aqua";
        "operator" = "orange";
        "function" = "green";
        "function.builtin" = "blue";
        "function.macro" = "aqua";
        "tag" = "yellow";
        "namespace" = "aqua";
        "attribute" = "aqua";
        "constructor" = "yellow";
        "module" = "blue";
        "special" = "orange";

        "markup.heading.marker" = "grey2";
        "markup.heading.1" = {
          fg = "red";
          modifiers = ["bold"];
        };
        "markup.heading.2" = {
          fg = "orange";
          modifiers = ["bold"];
        };
        "markup.heading.3" = {
          fg = "yellow";
          modifiers = ["bold"];
        };
        "markup.heading.4" = {
          fg = "green";
          modifiers = ["bold"];
        };
        "markup.heading.5" = {
          fg = "blue";
          modifiers = ["bold"];
        };
        "markup.heading.6" = {
          fg = "fg0";
          modifiers = ["bold"];
        };
        "markup.list" = "red";
        "markup.bold" = {modifiers = ["bold"];};
        "markup.italic" = {modifiers = ["italic"];};
        "markup.link.url" = {
          fg = "blue";
          modifiers = ["underlined"];
        };
        "markup.link.text" = "purple";
        "markup.quote" = "grey2";
        "markup.raw" = "green";

        "diff.plus" = "green";
        "diff.delta" = "orange";
        "diff.minus" = "red";

        "ui.background" = {bg = "bg0";};
        "ui.background.separator" = "grey0";
        "ui.cursor" = {
          fg = "bg0";
          bg = "fg0";
        };
        "ui.cursor.match" = {
          fg = "orange";
          bg = "bg_visual_yellow";
        };
        "ui.cursor.insert" = {
          fg = "bg0";
          bg = "grey2";
        };
        "ui.cursor.select" = {
          fg = "bg0";
          bg = "blue";
        };
        "ui.cursorline.primary" = {bg = "bg1";};
        "ui.cursorline.secondary" = {bg = "bg1";};
        "ui.selection" = {bg = "bg3";};
        "ui.linenr" = "grey0";
        "ui.linenr.selected" = "fg0";
        "ui.statusline" = {
          fg = "fg0";
          bg = "bg3";
        };
        "ui.statusline.inactive" = {
          fg = "grey0";
          bg = "bg1";
        };
        "ui.statusline.normal" = {
          fg = "bg0";
          bg = "fg0";
          modifiers = ["bold"];
        };
        "ui.statusline.insert" = {
          fg = "bg0";
          bg = "yellow";
          modifiers = ["bold"];
        };
        "ui.statusline.select" = {
          fg = "bg0";
          bg = "blue";
          modifiers = ["bold"];
        };
        "ui.bufferline" = {
          fg = "grey0";
          bg = "bg1";
        };
        "ui.bufferline.active" = {
          fg = "fg0";
          bg = "bg3";
          modifiers = ["bold"];
        };
        "ui.popup" = {
          fg = "grey2";
          bg = "bg2";
        };
        "ui.window" = {
          fg = "grey0";
          bg = "bg0";
        };
        "ui.help" = {
          fg = "fg0";
          bg = "bg2";
        };
        "ui.text" = "fg0";
        "ui.text.focus" = "fg0";
        "ui.menu" = {
          fg = "fg0";
          bg = "bg3";
        };
        "ui.menu.selected" = {
          fg = "bg0";
          bg = "blue";
          modifiers = ["bold"];
        };
        "ui.virtual.whitespace" = {fg = "bg4";};
        "ui.virtual.indent-guide" = {fg = "bg4";};
        "ui.virtual.ruler" = {bg = "bg3";};

        "hint" = "blue";
        "info" = "aqua";
        "warning" = "yellow";
        "error" = "red";
        "diagnostic" = {underline = {style = "curl";};};
        "diagnostic.hint" = {
          underline = {
            color = "blue";
            style = "dotted";
          };
        };
        "diagnostic.info" = {
          underline = {
            color = "aqua";
            style = "dotted";
          };
        };
        "diagnostic.warning" = {
          underline = {
            color = "yellow";
            style = "curl";
          };
        };
        "diagnostic.error" = {
          underline = {
            color = "red";
            style = "curl";
          };
        };

        palette = {
          bg0 = "#f9f5d7";
          bg1 = "#f5edca";
          bg2 = "#f3eac7";
          bg3 = "#f2e5bc";
          bg4 = "#eee0b7";
          bg5 = "#ebdbb2";
          bg_statusline1 = "#f5edca";
          bg_statusline2 = "#f3eac7";
          bg_statusline3 = "#eee0b7";
          bg_diff_green = "#e4edc8";
          bg_visual_green = "#dde5c2";
          bg_diff_red = "#f8e4c9";
          bg_visual_red = "#f0ddc3";
          bg_diff_blue = "#e0e9d3";
          bg_visual_blue = "#d9e1cc";
          bg_visual_yellow = "#f9eabf";
          bg_current_word = "#f3eac7";

          fg0 = "#654735";
          fg1 = "#4f3829";
          red = "#c14a4a";
          orange = "#c35e0a";
          yellow = "#b47109";
          green = "#6c782e";
          aqua = "#4c7a5d";
          blue = "#45707a";
          purple = "#945e80";
          bg_red = "#ae5858";
          bg_green = "#6f8352";
          bg_yellow = "#a96b2c";

          grey0 = "#a89984";
          grey1 = "#928374";
          grey2 = "#7c6f64";
        };
      };
    };
  };
}
