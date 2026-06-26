{
  config,
  pkgs,
  llm-agents,
  ...
}: {
  programs.opencode = {
    enable = pkgs.stdenv.isLinux;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

    extraPackages = with pkgs; [
      #### Helper tools ####
      nodejs
      pnpm

      #### Linters ####
      rslint
      ruff
      shellcheck

      #### Formatters ####
      alejandra
      ktlint
      shfmt
      texlivePackages.latexindent
      uv

      ##### Language server dependencies ####
      bash-language-server
      biome
      dockerfile-language-server
      jdk
      nixd
      texlab
      ty
      yaml-language-server
    ];

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

      ## Committing Code

      Git commit signing is required, but the location of the signing key is context dependent.

      - If the GIT_SIGNING_KEY environment variable is set, then use `git -c user.signingKey="key::$GIT_SIGNING_KEY"`.
      - If the GIT_SIGNING_KEY environment variable is not set but the id_ed25519 SSH key exists, then use `git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519"`.
      - If the GIT_SIGNING_KEY environment variable is not set and the id_ed25519 SSH key does not exist, then no signing key is available and you will need to ask the user for assistance when committing code.
    '';

    agents.code-review = ''
      ---
      description: Review code for security, quality, and best practices
      mode: subagent
      model: opencode/gpt-5.5-pro
      temperature: 0.2
      ---
      Review the code in this repository for security and best practices. DO NOT MAKE ANY CHANGES.

      Focus on the following areas:

      - **Security:** Are there any business logic flaws or other patterns that could lead to potential security issues, either alone or in combination with other problematic code? Are all dependencies up to date? Are all secrets handled is a safe fashion? Are any configuration options that could lead to a weakened security posture properly documented?
      - **Code quality:** Does the code follow the accepted best practices of the language in which it is written? Is there dead code that can be removed? Is there duplicative code that can be reasonably combined into a single functional unit? Is the code written in a clear, modular fashion? Is the code written in an economical fashion? Is the code written in a way that is clear and as self-documenting as possible?
      - **Documentation quality:** Do comments accurately reflect the functionality of the code with which they are associated? Do important or significant blocks of code lack comments? Does documentation included in the repository accurately reflect the current state of the code base? Are there any obvious gaps in the included documentation?

      Results should be written to a document in the root of the working tree called CODE_REVIEW_RESULTS.md, consisting of a series of Markdown todo items, each of which represents a single issue and recommend remediation approach. If this file already exists, append the results to the end using a header with the date and time of the analysis to separate new results from those previously reported. The command `date "+%Y-%m-%d %H:%M` can be used to output the current date and time for this purpose. Do not duplicate any findings that already exist.
    '';

    settings = {
      model = "opencode/claude-opus-4-8";
      small_model = "opencode/claude-haiku-4-5";
      shell = "bash";
      permission = "allow"; # YOLO mode
      lsp = true;
      formatter = {
        nixfmt = {
          disabled = true;
        };
        alejandra = {
          command = [
            "${pkgs.alejandra}/bin/alejandra"
            "$FILE"
          ];
          extensions = [".nix"];
        };
      };
    };
    tui = {
      theme = "gruvbox";
    };
  };
}
