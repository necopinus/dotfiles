{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude-code = pkgs.callPackage ./pkgs/claude-code.nix {};
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
  };
in {
  home.packages = with pkgs;
    lib.optionals pkgs.stdenv.isLinux [
      #### Bash ####
      shellcheck
      shfmt

      #### JavaScript / Typescript ####
      nodejs
      pnpm
      prettier
      rslint

      #### Python ####
      ruff
      uv

      #### Language server dependencies ####
      localPkgs.pyright
      localPkgs.pyright-langserver
      typescript
      typescript-language-server
    ];

  programs.claude-code = {
    enable = true;

    package =
      if pkgs.stdenv.isLinux
      then llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      else localPkgs.claude-code;

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

      **Write code, comments, and documentation so that a future version of yourself (or the human working with you) will be able to understand this project quickly and with minimal tokens.**

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

      Prefer LSP over Grep/Glob/Read for code navigation **within your own code (not all functions are available for files and libraries matched by a repo's .gitignore)**:

      - `goToDefinition` / `goToImplementation` to jump to source
      - `findReferences` to see all usages across the codebase
      - `workspaceSymbol` to find where something is defined
      - `documentSymbol` to list all symbols in a file
      - `hover` for type info without reading the file
      - `incomingCalls` / `outgoingCalls` for call hierarchy

      Before renaming or changing a function signature, use `findReferences` to find all call sites first.

      Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

      After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.

      ### LSP Limitation: No Navigation Into Git-Ignored Paths

      The LSP tool **silently discards location results that match a repository's .gitignore file (such as `.venv/`, `node_modules/`, build outputs, etc.). This is intentional harness behavior, *not* an LSP-server bug (the server resolves the symbol correctly, but the harness filters out the result). It cannot be overridden by changing language servers or harness settings.

      What breaks when the target lives in a git-ignored path (e.g. a dependency):

      - `goToDefinition` / `goToImplementation` returns "No definition found"
      - `findReferences` returns only the tracked references **(silently incomplete)**
      - `workspaceSymbol` omits symbols defined in git-ignored files

      What still works into git-ignored code:

      - `hover` still returns full type/signature/docstring (reads file content, not a location)
      - `documentSymbol` can still be passed the dependency file's path to explicitly list its symbols
      - `incomingCalls` / `outgoingCalls` still resolved call hierarchy into ignored targets

      To inspect a dependency/library, `hover` on the symbol, open the file directly with `documentSymbol`, or fall back to Grep/Read inside the dependency directory. When refactoring, remember `findReferences` only covers tracked files, and will miss usages in any git-ignored generated/build directories.

      ## Committing Code

      Git commit signing is required, but the location of the signing key is context dependent.

      - If the GIT_SIGNING_KEY environment variable is set, then use `git -c user.signingKey="key::$GIT_SIGNING_KEY"`.
      - If the GIT_SIGNING_KEY environment variable is not set but the id_ed25519 SSH key exists, then use `git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519"`.
      - If the GIT_SIGNING_KEY environment variable is not set and the id_ed25519 SSH key does not exist, then no signing key is available and you will need to ask the user for assistance when committing code.
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
      effortLevel = "xhigh";
      skipDangerousModePermissionPrompt = true;
      theme = "dark-ansi"; # `light-ansi` is more sensible, but diffs are unreadable
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
  # We add this flag as an alias so that we can still call Claude
  # without this flag when desired (by directly calling
  # ~/.nix-profile/bin/claude)
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
