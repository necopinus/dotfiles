{pkgs, ...}: {
  programs.ripgrep.enable = true;
  programs.uv.enable = true;

  home.packages = with pkgs; [
    claude-code

    #### Sandbox ####
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
  ];
  
  home.file.".claude/settings.json".source = ../artifacts/claude/settings.json;
}
