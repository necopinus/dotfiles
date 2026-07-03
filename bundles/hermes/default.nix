{
  pkgs,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # llm-agents defined in flake.nix

  localPkgs = {
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
  };
in {
  home.packages = with pkgs; [
    llmAgents.hermes-agent

    #### Additional deps ####
    playwright-test
    tirith

    ##### LSP servers & dependencies ####
    bash-language-server
    dockerfile-language-server
    kotlin-language-server
    jdt-language-server
    localPkgs.pyright
    localPkgs.pyright-langserver
    nixd
    shellcheck
    typescript
    typescript-language-server
    yaml-language-server
  ];

  programs.npm.enable = true; # Just use Nix to avoid NodeJs package conflicts
  programs.ripgrep.enable = pkgs.stdenv.isDarwin; # Installed at the system level on Linux
  programs.uv.enable = true;
}
