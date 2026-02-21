{
  config,
  pkgs,
  ...
}: {
  programs.uv.enable = true;

  home.packages = with pkgs;
    [
      claude-code
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

  # Environment variables
  #
  home.sessionVariables.CLAUDE_CODE_SHELL = "${pkgs.bashInteractive}/bin/bash";

  # Configuration files
  #
  home.file.".claude/settings.json".source = ../artifacts/claude/settings.json;
  xdg.configFile."nono/profiles/claude-code.json".text = ''
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
          "${config.home.homeDirectory}/.claude"
          "${config.xdg.cacheHome}/fish",
          "${config.xdg.cacheHome}/go-build",
          "${config.xdg.cacheHome}/pip",
          "${config.xdg.cacheHome}/pnpm",
          "${config.xdg.cacheHome}/starship",
          "${config.xdg.cacheHome}/uv",
          "${config.xdg.configHome}/fish",
          "${config.xdg.configHome}/go",
          "${config.xdg.configHome}/zsh",
          "${config.xdg.dataHome}/delta",
          "${config.xdg.dataHome}/fish",
          "${config.xdg.dataHome}/pnpm",
          "${config.xdg.stateHome}/pnpm",
          "/tmp",
          "/var/folders"
        ],
        "read": [
          "${config.home.homeDirectory}/.ssh",
          "${config.xdg.cacheHome}/bat",
          "${config.xdg.configHome}",
          "/etc/skel",
          "/nix",
          "/usr/share"
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
}
