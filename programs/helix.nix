{
  lib,
  pkgs,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
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
  xdg.configFile."moxide/settings.toml".source = ../artifacts/config/moxide/settings.toml;

  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = helperPkgs;

    # Helix inexplicably doesn't support auto-formatting of .nix files
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
      theme = "gruvbox";

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

  # Fix Helix theme support in the Android VM
  #
  home.sessionVariables = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    COLORTERM = "truecolor";
  };
}
