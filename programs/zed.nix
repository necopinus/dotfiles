{
  config,
  pkgs,
  ...
}: {
  xdg.configFile."marksman/config.toml".source = ../artifacts/config/marksman/config.toml;

  programs.zed-editor = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.symlinkJoin {
          name = "zed-editor-android-vm";
          paths = [pkgs.pkgs.zed-editor-fhs];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/zeditor \
              --unset VK_ICD_FILENAMES \
              --set ZED_ALLOW_EMULATED_GPU 1
          '';
        }
      else pkgs.zed-editor;

    extraPackages = with pkgs; [
      #### LSPs ####
      basedpyright
      bash-language-server
      clang-tools
      docker-compose-language-service
      dockerfile-language-server
      gopls
      haskellPackages.haskell-language-server
      jdt-language-server
      kotlin-language-server
      lua-language-server
      nixd
      powershell-editor-services
      rubyPackages.solargraph
      ruff
      rust-analyzer
      texlab
      tombi
      vscode-langservers-extracted
      vtsls
      yaml-language-server

      #### Formatters ####
      alejandra
      prettier
      shellcheck
      shfmt
      sql-formatter
    ];

    extensions = [
      "awk"
      "basher"
      "docker-compose"
      "dockerfile"
      "fish"
      "haskell"
      "html"
      "java"
      "jq"
      "jsonl"
      "kotlin"
      "latex"
      "lua"
      "make"
      "marksman"
      "nix"
      "powershell"
      "rst"
      "ruby"
      "solidity"
      "sql"
      "swift"
      "toml"
      "xml"
    ];

    userSettings = {
      auto_indent_on_paste = true;
      format_on_save = "on";
      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_size = 12;
      ui_font_size = 14;

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

      file_types = {
        Dockerfile = ["Dockerfile.*"];
        XML = ["rdf" "gpx" "kml"];
      };

      lsp = {
        powershell-es = {
          binary = {
            path = "${pkgs.powershell-editor-services}/bin/powershell-editor-services";
          };
        };
        texlab = {
          settings = {
            texlab = {
              build = {
                onSave = false;
              };
            };
          };
        };
      };

      languages = {
        Fish = {
          formatter = {
            external = {
              command = "fish_indent";
            };
          };
        };
        Nix = {
          language_servers = ["nixd" "!nil"];
          formatter = {
            external = {
              command = "alejandra";
              arguments = ["--quiet" "--"];
            };
          };
        };
        "Shell Script" = {
          format_on_save = "on";
          formatter = {
            external = {
              command = "shfmt";
              arguments = ["--filename" "{buffer_path}" "--indent" "4"];
            };
          };
        };
        SQL = {
          formatter = {
            external = {
              command = "sql-formatter";
            };
          };
        };
        LaTeX = {
          formatter = "language_server";
        };
      };
    };
  };

  # Zed doesn't seem to see the programs installed using
  # programs.zed-editor.extraPackages on macOS, so we use this hack to
  # expose them explicitly in ~/.nix-profile/bin
  #
  home.packages = pkgs.lib.optionals pkgs.stdenv.isDarwin config.programs.zed-editor.extraPackages;
}
