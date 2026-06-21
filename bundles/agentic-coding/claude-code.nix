{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude-code = pkgs.callPackage ./pkgs/claude-code.nix {inherit llm-agents;};
  };
in {
  programs.claude-code = {
    enable = true;
    package = localPkgs.claude-code;

    configDir = "${config.xdg.configHome}/claude";
    context = ''
      ## Coding Guidance

      If you have not already developed a plan, do so before making any changes, no matter how simple the task. Never shy away from asking clarifying questions.

      **When writing code, prioritize readability, simplicity, and security.** Alway include comments that explain the purpose and functionality of significant code blocks in plain language. Make sure that variables have descriptive names, and prefer straight-forward solutions to "clever" approaches that are less intelligble. Always use secure coding practices, even if doing so results in slightly slower or less efficient code. If the project is large enough to span multiple files, it is large enough to use unit tests for input/output functionality.

      **Follow the UNIX philosophy.** In particular:

      - Write programs that do one thing and do it well
      - Write programs to work together
      - Write programs to handle text streams, because that is a universal interface

      Prioritize simple, readable programs that can be easily composed using pipes and input/putput redirection. Programs should be able to handle expected input types robustly, and fail in ways that are easy to diagnose. Balance economy of output with economy of tool calls - while unnecessary output should be avoided, also try to avoid situations where common operations require multiple tool calls to the same tool. In terms of the user experience, follow established UNIX conventions where it makes sense to do so, and cleanly separate configuration from actual business logic.

      **Write code, comments, and documentation so that a future version of yourself will be able to understand this project quickly and with minimal tokens.**

      Always run a formatter to ensure that code is presented consistently. The following formatters are already available:

      - `shfmt` (Bash-compatible code)
      - `prettier` (JavaScript and TypeScript)
      - `ruff` (Python)

      Always run a linter to check your code for potential issues. The following linters are already available:

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
    # Official plugins: https://github.com/anthropics/claude-plugins-official/tree/main/plugins
    #
    # Plugin dependencies should be added to the ./pkgs/claude-code.nix
    # wrapper
    #
    settings = {
      outputStyle = "Explanatory";
      model = "opus"; # TODO: Is it worth switching this to "fable"?
      alwaysThinkingEnabled = true;
      autoMemoryEnabled = true;
      autoDreamEnabled = true;
      skipDangerousModePermissionPrompt = true;
      theme = "light-ansi";
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
    };
  };

  # Not all of Claude's tool calls work correctly under non-bash shells
  #
  home.sessionVariables.CLAUDE_CODE_SHELL = "bash";

  # YOLO mode by default
  #
  # We add this flag as an alias, rather than within the `claude`
  # wrapper, so that we can still call Claude without this flag when
  # desired (by directly calling ~/.nix-profile/bin/claude)
  #
  xdg.configFile."bash/rc.d/claude.sh" = {
    enable = config.programs.bash.enable && pkgs.stdenv.isLinux;
    text = ''
      alias claude="${config.programs.claude-code.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."zsh/rc.d/claude.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.isLinux;
    text = ''
      alias claude="${config.programs.claude-code.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."fish/rc.d/claude.fish" = {
    enable = config.programs.fish.enable && pkgs.stdenv.isLinux;
    text = ''
      alias claude "${config.programs.claude-code.package}/bin/claude --dangerously-skip-permissions"
    '';
  };
}
