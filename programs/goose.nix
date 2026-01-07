{
  pkgs,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # Set in flake.nix overlay
in {
  home.packages = with pkgs; [
    llmAgents.goose-cli # Set in flake.nix overlay
  ];

  xdg.configFile = {
    "goose/config.yaml".source = ../artifacts/config/goose/config.yaml;
  };
}
