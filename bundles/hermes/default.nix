{
  pkgs,
  config,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # llm-agents defined in flake.nix

  localPkgs = {
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
  };
in {
  # IMPORTANT: We do NOT install llmAgents.hermes-agent, as it's just
  # missing too many bits. Instead, we install using the official "curl
  # a script from some random website into bash" method.
  #
  #   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
  #
  home.packages = with pkgs; [
    #### Additional deps ####
    llmAgents.agent-browser
    playwright-test
    tirith

    #### Tools ####
    jsonschema
    python3Packages.weasyprint

    #### LSP servers & dependencies ####
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

    #### MCP servers & dependencies ####
    markitdown-mcp
    officecli
  ];

  programs.npm.enable = true; # Just use Nix to avoid NodeJs package conflicts
  programs.ripgrep.enable = pkgs.stdenv.isDarwin; # Installed at the system level on Linux
  programs.uv.enable = true;

  # Add ByteRover CLI to PATH
  #
  #   curl -fsSL https://byterover.dev/install.sh | bash
  #
  xdg.configFile."bash/env.d/byterover.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      export PATH="$PATH:$HOME/.brv-cli/bin"
    '';
  };
  xdg.configFile."zsh/env.d/byterover.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      export PATH="$PATH:$HOME/.brv-cli/bin"
    '';
  };
  xdg.configFile."fish/env.d/byterover.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      fish_add_path $HOME/.brv-cli/bin
    '';
  };

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/hermes.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias hermes="$(which hermes) --tui"
      alias ob="${config.programs.npm.package}/bin/npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."zsh/rc.d/hermes.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias hermes="$(which hermes) --tui"
      alias ob="${config.programs.npm.package}/bin/npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."fish/rc.d/hermes.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias hermes "$(which hermes) --tui"
      alias ob="${config.programs.npm.package}/bin/npx --package=obsidian-headless --yes -- ob"
    '';
  };
}
