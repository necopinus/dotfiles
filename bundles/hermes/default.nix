{
  pkgs,
  lib,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # llm-agents defined in flake.nix

  localPkgs = {
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
  };
in {
  home.packages = with pkgs;
    lib.optionals pkgs.stdenv.isLinux [
      llmAgents.hermes-agent
      llmAgents.hermes-hud

      #### Additional deps ####
      playwright

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
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      llmAgents.hermes-desktop
    ];

  programs.npm.enable = true;
  programs.ripgrep.enable = true;
  programs.uv.enable = true;
}
