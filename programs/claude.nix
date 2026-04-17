{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {inherit llm-agents;};
  };

  claudeInChrome = {
    extensionId = "fcoeoabgfenejglbffodgkkbkcdhcgfn";
    nativeHostName = "com.anthropic.claude_code_browser_extension";
    nativeHostConfig = ''
      {
        "name": "${claudeInChrome.nativeHostName}",
        "description": "Claude Code Browser Extension Native Host",
        "path": "${config.home.homeDirectory}/.claude/chrome/chrome-native-host",
        "type": "stdio",
        "allowed_origins": [
          "chrome-extension://${claudeInChrome.extensionId}/",
        ]
      }
    '';
  };
in {
  #################### Claude Code ####################

  programs.claude-code = {
    enable = true;
    package = localPkgs.claude;

    # IMPORTANT: You cannot use both nono and Claude's built-in sandboxing at
    # the same time!
    #
    settings = {
      tui = "fullscreen";
      outputStyle = "Explanatory";
      model = "opus";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      enabledPlugins = {
        "clangd-lsp@claude-plugins-official" = true;
        "csharp-lsp@claude-plugins-official" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "jdtls-lsp@claude-plugins-official" = true;
        "kotlin-lsp@claude-plugins-official" = true;
        "lua-lsp@claude-plugins-official" = true;
        "php-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "swift-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
      hooks = {
        PostToolUseFailure = [
          {
            hooks = [
              {
                # Must be $HOME and not ${config.home.homeDirectory},
                # or nono's autodetction will fail and the sandbox will
                # pull an error
                #
                command = "$HOME/.claude/hooks/nono-hook.sh";
                type = "command";
              }
            ];
            matcher = "Read|Write|Edit|Bash";
          }
        ];
      };
    };
  };

  home.file.".claude/CLAUDE.md".source = ../artifacts/claude/CLAUDE.md;

  # Claude expects a kotlin-lsp binary, but Nixpkgs provides
  # kotlin-language-server
  #
  home.file.".local/bin/kotlin-lsp".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.kotlin-language-server}/bin/kotlin-language-server";

  # Use Claude in Chrome with Chromium
  #
  programs.chromium.extensions = [
    {id = "${claudeInChrome.extensionId}";} # Claude for Chrome
  ];
  xdg.configFile."chromium/Default/Extensions/.keep" = {
    enable = config.programs.chromium.enable;
    text = "";
  };
  xdg.configFile."chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json" = {
    enable = config.programs.chromium.enable;
    text = "${claudeInChrome.nativeHostConfig}";
  };
  xdg.configFile."google-chrome/Default/Extensions" = {
    enable = config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/Default/Extensions";
  };
  xdg.configFile."google-chrome/NativeMessagingHosts" = {
    enable = config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/NativeMessagingHosts";
  };

  #################### Nono ####################

  # Read access to Chromium / Google Chrome directories is necessary for
  # browser integrtion to work
  #
  # Read access to Bash configuration files is necessary to ensure that
  # shell calls work as expected
  #
  xdg.configFile."nono/profiles/claude-code-local.json".text = ''
    {
      "meta": {
        "name": "claude-code-local"
      },
      "extends": "claude-code",
      "security": {
        "groups": [
          "go_runtime"
        ]
      },
      "filesystem": {
        "read": [
          "${config.home.homeDirectory}/Library/Application Support/Chromium",
          "${config.xdg.configHome}/chromium",
          "${config.home.homeDirectory}/Library/Application Support/Google/Chrome",
          "${config.xdg.configHome}/google-chrome",
          "/etc/bash_completion.d",
          "/etc/profile.d"
        ],
        "read_file": [
          "${config.home.homeDirectory}/.bash_aliases",
          "${config.home.homeDirectory}/.bash_profile",
          "${config.home.homeDirectory}/.bashrc",
          "${config.home.homeDirectory}/.profile",
          "/etc/bash.bashrc",
          "/etc/bashrc",
          "/etc/profile",
          "/etc/skel/.bash_profile",
          "/etc/skel/.bashrc",
          "/etc/skel/.profile"
        ]
      }
    }
  '';
}
