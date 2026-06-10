{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {inherit llm-agents;};
    kotlin-lsp = pkgs.callPackage ../pkgs/kotlin-lsp.nix {};
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

    configDir = "${config.xdg.configHome}/claude";
    context = ''
      ## Coding Guidance

      If you have not already developed a plan, do so before making any changes, no matter how simple the task. Never shy away from asking clarifying questions.

      **When writing code, prioritize readability, simplicity, and security.** Alway include comments that explain the purpose and functionality of significant code blocks in plain language. Make sure that variables have descriptive names, and prefer straight-forward solutions to "clever" approaches that are less intelligble. Always use secure coding practices, even if doing so results in slightly slower or less efficient code. If the project is large enough to span multiple files, it is large enough to use unit tests for input/output functionality.

      **Write code, comments, and documentation so that a future version of yourself will be able to understand this project quickly and with minimal tokens.**

      Always run a linter to check your code for obvious security problems. The following linters are already available:

      - `shellcheck` (Bash-compatible shell code)
      - `rslint` (JavaScript and TypeScript)
      - `ruff` (Python)

      If you need an additional linter, you should ask the user to install one. Never disable linter checks without first receiving approval from the user. **The project is not complete until all warnings and errors have been resolved.**

      ## Code Intelligence

      Prefer LSP over Grep/Glob/Read for code navigation:

      - `goToDefinition` / `goToImplementation` to jump to source
      - `findReferences` to see all usages across the codebase
      - `workspaceSymbol` to find where something is defined
      - `documentSymbol` to list all symbols in a file
      - `hover` for type info without reading the file
      - `incomingCalls` / `outgoingCalls` for call hierarchy

      Before renaming or changing a function signature, use `findReferences` to find all call sites first.

      Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

      After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.
    '';

    # IMPORTANT: You cannot use both nono and Claude's built-in sandboxing at
    # the same time!
    #
    settings = {
      tui = "fullscreen";
      outputStyle = "Explanatory";
      model = "opus";
      alwaysThinkingEnabled = true;
      autoMemoryEnabled = true;
      autoDreamEnabled = true;
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
        "ruby-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "swift-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
    };
  };

  # Claude expects a kotlin-lsp binary, but Nixpkgs provides
  # kotlin-language-server
  #
  home.packages = [
    localPkgs.kotlin-lsp
  ];

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
        "allow": [
          "${config.xdg.configHome}/claude"
        ],
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
