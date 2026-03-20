{
  config,
  pkgs,
  lib,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {};
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
      outputStyle = "Explanatory";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      enabledPlugins =
        {
          "clangd-lsp@claude-plugins-official" = true;
          "gopls-lsp@claude-plugins-official" = true;
          "jdtls-lsp@claude-plugins-official" = true;
          "kotlin-lsp@claude-plugins-official" = true;
          "lua-lsp@claude-plugins-official" = true;
          "php-lsp@claude-plugins-official" = true;
          "pyright-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
          "swift-lsp@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
        }
        // lib.attrsets.optionalAttrs (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") {
          "csharp-lsp@claude-plugins-official" = true; # LSP currently broken on macOS ARM
        };
      hooks = {
        PostToolUseFailure = [
          {
            hooks = [
              {
                command = "${config.home.homeDirectory}/.claude/hooks/nono-hook.sh";
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
  home.file."Library/Application Support/Chromium/Default/Extensions/.keep" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    text = "";
  };
  home.file."Library/Application Support/Chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    text = "${claudeInChrome.nativeHostConfig}";
  };
  home.file."Library/Application Support/Google/Chrome/Default/Extensions" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/Default/Extensions";
  };
  home.file."Library/Application Support/Google/Chrome/NativeMessagingHosts" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/NativeMessagingHosts";
  };
  xdg.configFile."chromium/Default/Extensions/.keep" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    text = "";
  };
  xdg.configFile."chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    text = "${claudeInChrome.nativeHostConfig}";
  };
  xdg.configFile."google-chrome/Default/Extensions" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/Default/Extensions";
  };
  xdg.configFile."google-chrome/NativeMessagingHosts" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/NativeMessagingHosts";
  };

  #################### Nono ####################

  xdg.configFile."nono/profiles/claude-code.toml".text = ''
    interactive = true

    [meta]
    name = "claude-code"
    version = "1.0.1"
    description = "Anthropic Claude Code CLI agent"
    "author" = "Nathan Acks (based on the default nono claude-code profile)"

    [filesystem]
    allow = [
      "${config.home.homeDirectory}/.claude",
      "${config.xdg.cacheHome}",
      "${config.xdg.configHome}/go",
      "${config.xdg.dataHome}/claude",
      "${config.xdg.dataHome}/pnpm",
      "${config.xdg.stateHome}/pnpm",
      "/tmp",
      "/var/folders"
    ]
    read = [
      "${config.home.homeDirectory}/Library/Application Support/Chromium",
      "${config.home.homeDirectory}/Library/Application Support/Google/Chrome",
      "${config.xdg.configHome}/chromium",
      "${config.xdg.configHome}/google-chrome",
      "/etc/skel",
      "/nix"
    ]
    allow_file = [
      "${config.home.homeDirectory}/.claude.json",
      "${config.home.homeDirectory}/.claude.json.lock",
      "${config.home.homeDirectory}/.claude.lock",
      "${config.home.homeDirectory}/Library/Keychains/login.keychain-db", # Needs to be read/write or credential refreshes fail
      "/dev/null"
    ]
    read_file = [
      "${config.home.homeDirectory}/.bash_aliases",
      "/etc/bashrc"
    ]

    [network]
    block = false

    [workdir]
    access = "readwrite"

    [hooks.claude-code]
    event = "PostToolUseFailure"
    matcher = "Read|Write|Edit|Bash"
    script = "nono-hook.sh"
  '';
}
