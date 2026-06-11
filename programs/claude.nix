{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {inherit llm-agents;};
  };
in {
  #################### Claude Code ####################

  programs.claude-code = {
    enable = true;
    package = localPkgs.claude;

    configDir = "${config.xdg.configHome}/claude";
    context = ''
      ## Coding Guidance

      If you have not already developed a plan, do so before making any changes, no matter how simple the task. Never shy away from asking clarifying questions.

      **When writing code, prioritize readability, simplicity, and security.** Alway include comments that explain the purpose and functionality of significant code blocks in plain language. Make sure that variables have descriptive names, and prefer straight-forward solutions to "clever" approaches that are less intelligble. Always use secure coding practices, even if doing so results in slightly slower or less efficient code. If the project is large enough to span multiple files, it is large enough to use unit tests for input/output functionality.

      **Write code, comments, and documentation so that a future version of yourself will be able to understand this project quickly and with minimal tokens.**

      Always run a linter to check your code for obvious security problems. The following linters are already available:

      - `shellcheck` (Bash-compatible shell code)
      - `rslint` (JavaScript and TypeScript)
      - `ruff` (Python)

      If you need an additional linter, you should ask the user to install one. Never disable linter checks without first receiving approval from the user. **The project is not complete until all warnings and errors have been resolved.**

      ## Code Intelligence

      Prefer LSP over Grep/Glob/Read for code navigation:

      - `goToDefinition` / `goToImplementation` to jump to source
      - `findReferences` to see all usages across the codebase
      - `workspaceSymbol` to find where something is defined
      - `documentSymbol` to list all symbols in a file
      - `hover` for type info without reading the file
      - `incomingCalls` / `outgoingCalls` for call hierarchy

      Before renaming or changing a function signature, use `findReferences` to find all call sites first.

      Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

      After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.
    '';

    # Sandbox isn't configured here, as we only use Claude Code in
    # isolated VMs, allowing us to go full YOLO-mode
    #
    settings = {
      tui = "fullscreen";
      outputStyle = "Explanatory";
      model = "opus"; # TODO: Is it worth switching this to "fable"?
      alwaysThinkingEnabled = true;
      autoMemoryEnabled = true;
      autoDreamEnabled = true;
      skipDangerousModePermissionPrompt = true;
      enabledPlugins = {
        "clangd-lsp@claude-plugins-official" = true;
        "csharp-lsp@claude-plugins-official" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "jdtls-lsp@claude-plugins-official" = true;
        "kotlin-lsp@claude-plugins-official" = true;
        "lua-lsp@claude-plugins-official" = true;
        "php-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
        "ruby-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "swift-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
    };
  };

  # Not all of Claude's tool calls work correctly unless the bash from
  # pkgs.bashInteractive is used
  #
  home.sessionVariables.CLAUDE_CODE_SHELL = "${pkgs.bashInteractive}/bin/bash";

  # YOLO mode by default
  #
  # We add this flag as an alias, rather than within the `claude`
  # wrapper, so that we can still call Claude without this flag when
  # desired (by directly calling ~/.nix-profile/bin/claude)
  #
  xdg.configFile."bash/rc.d/claude.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias claude="${config.programs.claud.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."zsh/rc.d/claude.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias claude="${config.programs.claud.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."fish/rc.d/claude.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias claude "${config.programs.claud.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
}
