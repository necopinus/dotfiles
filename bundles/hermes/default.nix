{
  pkgs,
  lib,
  llm-agents,
  ...
}: {
  home.packages =
    lib.optionals pkgs.stdenv.isLinux [
      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-hud
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-desktop
    ];
}
