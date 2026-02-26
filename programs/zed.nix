{
  pkgs,
  lib,
  config,
  ...
}: let
  helperPkgs = with pkgs; [
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
    markdown-oxide
    nixd
    powershell-editor-services
    rubyPackages.solargraph
    ruff
    rust-analyzer
    solc
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
in {
  # Make sure that the packages we'd normally install as
  # programs.zed-editor.extraPackages are available to Zed on macOS
  #
  home.packages = lib.optionals pkgs.stdenv.isDarwin helperPkgs;

  xdg.configFile."moxide/settings.toml".source = ../artifacts/config/moxide/settings.toml;

  programs.zed-editor = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.symlinkJoin {
          name = "zed-editor-debian";
          paths = [pkgs.zed-editor-fhs];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/zeditor \
              --unset VK_ICD_FILENAMES \
              --set ZED_ALLOW_EMULATED_GPU 1 # Zed doesn't like the Android VM's virtual GPU
          '';
        }
      else null;

    extraPackages = lib.optionals pkgs.stdenv.isLinux helperPkgs;

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
      "markdown-oxide"
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
      show_whitespaces = "selection";
      soft_wrap = "editor_width";
      auto_indent = true;
      auto_indent_on_paste = true;
      format_on_save = "on";
      excerpt_context_lines = 5;
      #buffer_font_family = "JetBrainsMono Nerd Font Mono"; # TODO: Uncomment once the Android Terminal supports custom fonts
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
              command = "${pkgs.fish}/bin/fish_indent";
            };
          };
        };
        Nix = {
          language_servers = ["nixd" "!nil"];
          formatter = {
            external = {
              command = "${pkgs.alejandra}/bin/alejandra";
              arguments = ["--quiet" "--"];
            };
          };
        };
        "Shell Script" = {
          format_on_save = "on";
          formatter = {
            external = {
              command = "${pkgs.shfmt}/bin/shfmt";
              arguments = ["--filename" "{buffer_path}" "--indent" "4"];
            };
          };
        };
        SQL = {
          formatter = {
            external = {
              command = "${pkgs.sql-formatter}/bin/sql-formatter";
            };
          };
        };
        LaTeX = {
          formatter = "language_server";
        };
      };
    };
  };

  # Convenience aliases (Darwin only)
  #
  xdg.configFile."bash/rc.d/zed.sh" = {
    enable = pkgs.stdenv.isDarwin && config.programs.bash.enable;
    text = ''
      if [[ -n "$(${pkgs.which}/bin/which zed)" ]]; then
        if [[ -d /Applications/Zed.app ]]; then
          alias zed="$(${pkgs.which}/bin/which zed) --zed /Applications/Zed.app"
          alias zeditor="$(${pkgs.which}/bin/which zed) --zed /Applications/Zed.app"
        elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
          alias zed="$(${pkgs.which}/bin/which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor="$(${pkgs.which}/bin/which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        fi
      elif [[ -n "$(${pkgs.which}/bin/which zeditor)" ]]; then
        if [[ -d /Applications/Zed.app ]]; then
          alias zed="$(${pkgs.which}/bin/which zeditor) --zed /Applications/Zed.app"
          alias zeditor="$(${pkgs.which}/bin/which zeditor) --zed /Applications/Zed.app"
        elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
          alias zed="$(${pkgs.which}/bin/which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor="$(${pkgs.which}/bin/which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        fi
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/zed.sh" = {
    enable = pkgs.stdenv.isDarwin && config.programs.zsh.enable;
    text = ''
      if [[ -n "$(whence -p zed)" ]]; then
        if [[ -d /Applications/Zed.app ]]; then
          alias zed="$(whence -p zed) --zed /Applications/Zed.app"
          alias zeditor="$(whence -p zed) --zed /Applications/Zed.app"
        elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
          alias zed="$(whence -p zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor="$(whence -p zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        fi
      elif [[ -n "$(whence -p zeditor)" ]]; then
        if [[ -d /Applications/Zed.app ]]; then
          alias zed="$(whence -p zeditor) --zed /Applications/Zed.app"
          alias zeditor="$(whence -p zeditor) --zed /Applications/Zed.app"
        elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
          alias zed="$(whence -p zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor="$(whence -p zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        fi
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zed.fish" = {
    enable = pkgs.stdenv.isDarwin && config.programs.fish.enable;
    text = ''
      if test -n "$(${pkgs.which}/bin/which zed)"
        if test -d /Applications/Zed.app
          alias zed "$(${pkgs.which}/bin/which zed) --zed /Applications/Zed.app"
          alias zeditor "$(${pkgs.which}/bin/which zed) --zed /Applications/Zed.app"
        else if test -d "$HOME/Applications/Home Manager Apps/Zed.app"
          alias zed "$(${pkgs.which}/bin/which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor "$(${pkgs.which}/bin/which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        end
      else if test -n "$(${pkgs.which}/bin/which zeditor)"
        if test -d /Applications/Zed.app
          alias zed "$(${pkgs.which}/bin/which zeditor) --zed /Applications/Zed.app"
          alias zeditor "$(${pkgs.which}/bin/which zeditor) --zed /Applications/Zed.app"
        else if test -d "$HOME/Applications/Home Manager Apps/Zed.app"
          alias zed "$(${pkgs.which}/bin/which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          alias zeditor "$(${pkgs.which}/bin/which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
        end
      end
    '';
  };
}
