{
  config,
  lib,
  pkgs,
  ...
}: let
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
  programs.claude-code = {
    enable = true;

    settings = {
      outputStyle = "Explanatory";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      permissions = {
        deny = [
          "Bash(su *)"
          "Bash(sudo *)"
          "Edit(/${config.home.homeDirectory}/.cert)"
          "Edit(/${config.home.homeDirectory}/.gitconfig)"
          "Edit(/${config.home.homeDirectory}/.gnupg)"
          "Edit(/${config.home.homeDirectory}/.kde/share/apps/networkmanagement)"
          "Edit(/${config.home.homeDirectory}/.ssh)"
          "Edit(/${config.home.homeDirectory}/data)"
          "Edit(/${config.home.homeDirectory}/Desktop)"
          "Edit(/${config.home.homeDirectory}/Documents)"
          "Edit(/${config.home.homeDirectory}/Downloads)"
          "Edit(/${config.home.homeDirectory}/Library)"
          "Edit(/${config.home.homeDirectory}/Movies)"
          "Edit(/${config.home.homeDirectory}/Music)"
          "Edit(/${config.home.homeDirectory}/notes)"
          "Edit(/${config.home.homeDirectory}/Pictures)"
          "Edit(/${config.home.homeDirectory}/Public)"
          "Edit(/${config.home.homeDirectory}/Templates)"
          "Edit(/${config.home.homeDirectory}/Videos)"
          "Edit(/${config.xdg.configHome}/git)"
          "Edit(/${config.xdg.dataHome}/certs)"
          "Edit(/${config.xdg.dataHome}/keyrings)"
          "Edit(/${config.xdg.dataHome}/kwalletd)"
          "Edit(/${config.xdg.dataHome}/networkmanagement)"
          "Edit(//etc/NetworkManager)"
          "Edit(//etc/ssh)"
          "Edit(//mnt)"
          "Edit(//Volumes)"
          "Read(/${config.home.homeDirectory}/.cert)"
          "Read(/${config.home.homeDirectory}/.gnupg)"
          "Read(/${config.home.homeDirectory}/.kde/share/apps/networkmanagement)"
          "Read(/${config.home.homeDirectory}/data)"
          "Read(/${config.home.homeDirectory}/Desktop)"
          "Read(/${config.home.homeDirectory}/Documents)"
          "Read(/${config.home.homeDirectory}/Downloads)"
          "Read(/${config.home.homeDirectory}/Movies)"
          "Read(/${config.home.homeDirectory}/Music)"
          "Read(/${config.home.homeDirectory}/notes)"
          "Read(/${config.home.homeDirectory}/Pictures)"
          "Read(/${config.home.homeDirectory}/Public)"
          "Read(/${config.home.homeDirectory}/Templates)"
          "Read(/${config.home.homeDirectory}/Videos)"
          "Read(/${config.xdg.dataHome}/certs)"
          "Read(/${config.xdg.dataHome}/keyrings)"
          "Read(/${config.xdg.dataHome}/kwalletd)"
          "Read(/${config.xdg.dataHome}/networkmanagement)"
          "Read(//etc/NetworkManager)"
          "Read(//etc/ssh)"
          "Read(//mnt)"
          "Read(//Volumes)"
        ];
        ask = ["Bash(rm *)"];
        allow = [
          "Bash(ls *)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Chromium/Default/Extensions)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Chromium/NativeMessagingHosts)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Google/Chrome/Default/Extensions)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Google/Chrome/NativeMessagingHosts)"
          "Read(/${config.xdg.configHome}/chromium/Default/Extensions)"
          "Read(/${config.xdg.configHome}/chromium/NativeMessagingHosts)"
          "Read(/${config.xdg.configHome}/google-chrome/Default/Extensions)"
          "Read(/${config.xdg.configHome}/google-chrome/NativeMessagingHosts)"
        ];
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
        allowUnsandboxedCommands = false;
        network = {
          allowedDomains = [];
          allowUnixSockets = [];
          allowLocalBinding = true;
        };
        excludedCommands = [];
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

  # Make sure that Claude Code always uses bash for its shell
  #
  home.sessionVariables.CLAUDE_CODE_SHELL = "${pkgs.bashInteractive}/bin/bash";

  # Use Claude in Chrome with Chromium
  #
  programs.chromium.extensions = [
    {id = "${claudeInChrome.extensionId}";} # Claude for Chrome
  ];
  home.file = lib.attrsets.optionalAttrs (pkgs.stdenv.isDarwin && config.programs.chromium.enable) {
    "Library/Application Support/Chromium/Default/Extensions/.keep".text = "";
    "Library/Application Support/Chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json".text = "${claudeInChrome.nativeHostConfig}";
    "Library/Application Support/Google/Chrome/Default/Extensions".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/Default/Extensions";
    "Library/Application Support/Google/Chrome/NativeMessagingHosts".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/NativeMessagingHosts";
  };
  xdg.configFile =
    lib.attrsets.optionalAttrs (pkgs.stdenv.isLinux && config.programs.chromium.enable) {
      "chromium/Default/Extensions/.keep".text = "";
      "chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json".text = "${claudeInChrome.nativeHostConfig}";
      "google-chrome/Default/Extensions".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/Default/Extensions";
      "google-chrome/NativeMessagingHosts".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/NativeMessagingHosts";
    }
    // {
      # Customized nono profile
      #
      "nono/profiles/claude-code.json".text = ''
        {
          "meta": {
            "name": "claude-code",
            "version": "1.0.1",
            "description": "Anthropic Claude Code CLI agent",
            "author": "Nathan Acks (based on default nono profile)"
          },
          "security": {
            "groups": [
              "go_runtime",
              "node_runtime",
              "python_runtime",
              "rust_runtime",
              "unlink_protection",
              "user_caches_macos"
            ]
          },
          "trust_groups": [],
          "filesystem": {
            "allow": [
              "${config.home.homeDirectory}/.bash_sessions"
              "${config.home.homeDirectory}/.claude"
              "${config.xdg.cacheHome}/fish",
              "${config.xdg.cacheHome}/go-build",
              "${config.xdg.cacheHome}/pip",
              "${config.xdg.cacheHome}/pnpm",
              "${config.xdg.cacheHome}/starship",
              "${config.xdg.cacheHome}/uv",
              "${config.xdg.configHome}/go",
              "${config.xdg.configHome}/zsh",
              "${config.xdg.dataHome}/fish",
              "${config.xdg.dataHome}/pnpm",
              "${config.xdg.stateHome}/pnpm",
              "/tmp",
              "/var/folders"
            ],
            "read": [
              "${config.home.homeDirectory}/.ssh",
              "${config.home.homeDirectory}/Library/Application Support/Chromium",
              "${config.home.homeDirectory}/Library/Application Support/Google/Chrome",
              "${config.xdg.cacheHome}/bat",
              "${config.xdg.configHome}/chromium",
              "${config.xdg.configHome}/fish",
              "${config.xdg.configHome}/google-chrome",
              "${config.xdg.configHome}/starship",
              "/etc/skel",
              "/nix"
            ],
            "allow_file": [
              "${config.home.homeDirectory}/.claude.json",
              "/dev/null"
            ],
            "read_file": [
              "${config.home.homeDirectory}/.bash_aliases",
              "${config.home.homeDirectory}/Library/Keychains/login.keychain-db",
              "/etc/bashrc"
            ]
          },
          "network": {
            "block": false
          },
          "workdir": {
            "access": "readwrite"
          },
          "hooks": {
            "claude-code": {
              "event": "PostToolUseFailure",
              "matcher": "Read|Write|Edit|Bash",
              "script": "nono-hook.sh"
            }
          },
          "undo": {
            "exclude_patterns": [
              "node_modules",
              ".next",
              "__pycache__",
              "target"
            ],
            "exclude_globs": [
              "*.tmp.[0-9]*.[0-9]*"
            ]
          },
          "interactive": true
        }
      '';
    };

  # Various helper packages
  #
  programs.uv.enable = true;
  home.packages = with pkgs;
    [
      nono

      #### Anthropic Sandbox Runtime (part of Claude Code) ####
      ripgrep
      socat

      #### Bash ####
      shellcheck
      shfmt

      #### JavaScript / Typescript ####
      nodejs
      pnpm
      prettier
      rslint

      #### Python ####
      python3
      ruff
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      strace # Used by the Anthropic Sandbox Runtime (part of Claude Code)
    ];
}
