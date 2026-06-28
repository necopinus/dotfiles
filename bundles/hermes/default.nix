{
  pkgs,
  lib,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # llm-agents defined in flake.nix
in {
  home.packages =
    lib.optionals pkgs.stdenv.isLinux [
      llmAgents.hermes-agent
      llmAgents.hermes-hud
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      llmAgents.hermes-desktop
    ];
}
