{pkgs, ...}: {
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

  home.file.".claude/settings.json".source = ../artifacts/claude/settings.json;
}
