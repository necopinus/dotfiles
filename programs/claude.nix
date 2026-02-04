{pkgs, ...}: {
  programs.uv.enable = true;

  home.packages = with pkgs; [
    claude-code

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
}
