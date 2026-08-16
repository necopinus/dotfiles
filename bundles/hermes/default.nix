{
  pkgs,
  config,
  llm-agents,
  ...
}: let
  llmAgents = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; # llm-agents defined in flake.nix

  localPkgs = {
    inaba = pkgs.callPackage ./pkgs/inaba.nix {};
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
  };
in {
  # TODO: Remove this fix once https://github.com/NixOS/nixpkgs/pull/545267
  # is live in nixpkgs-unstable
  #
  imports = [
    ./fixes/pandas-stubs-20260729.nix
  ];

  # IMPORTANT: We do NOT install llmAgents.hermes-agent, as it's just
  # missing too many bits. Instead, we install using the official "curl
  # a script from some random website into bash" method.
  #
  #   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
  #
  home.packages = with pkgs; [
    #### Convenience wrapper ####
    localPkgs.inaba

    #### Additional deps ####
    llmAgents.agent-browser
    playwright-test
    tirith

    #### Tools ####
    pandoc
    python3Packages.jsonschema
    python3Packages.weasyprint
    texliveFullWithDocs

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
    mcp-nixos
    officecli
  ];

  programs.npm.enable = true; # Just use Nix to avoid NodeJs package conflicts
  programs.ripgrep.enable = pkgs.stdenv.hostPlatform.isDarwin; # Installed at the system level on Linux
  programs.uv.enable = true;

  # Convenience aliases
  #
  # NOTE: We DON'T prefix 'npx' here, as we want to make sure to use the
  # same version of npx/npm/node as Hermes (this lives in ~/.local/bin,
  # and is inserted into the PATH before ~/.nix-profile/bin)
  #
  xdg.configFile."bash/rc.d/hermes.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."zsh/rc.d/hermes.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."fish/rc.d/hermes.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
  };
}
