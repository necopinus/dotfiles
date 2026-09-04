{
  config,
  pkgs,
  ...
}: {
  programs.opencode = {
    enable = true;

    extraPackages = with pkgs; [
      #### Helper tools ####
      nodejs

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

      **When writing code, prioritize readability, simplicity, and security.** Always include comments that explain the purpose and functionality of significant code blocks in plain language. Make sure that variables have descriptive names, and prefer straight-forward solutions to "clever" approaches that are less intelligble. Always use secure coding practices, even if doing so results in slightly slower or less efficient code. If the project is large enough to span multiple files, it is large enough to use unit tests for input/output functionality.

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

      ### Model Hierarchy & Subagent Delegation

      The primary agent and `@code-review` run on `opencode-go/minimax-m3`, a model that is capable but expensive. The built-in `@general` and `@explore` subagents run on `opencode-go/deepseek-v4-pro`. This model is cheaper but still capable of routine work. The `small_model` is `opencode-go/deepseek-v4-flash` for ephemeral background tasks.

      To minimize monetary cost and context window pressure, delegate routine work to subagents:

      - **Delegate exploration to `@explore`** instead of reading many files directly.
      - **Delegate multi-step routine work to `@general`** instead of executing it inline.
      - **Reserve direct tool use** for orchestration, planning, and review, where the primary agent's judgment is required.
      - **Pass concise task descriptions to subagents** and do not relay the full conversation history.

      `@explore` is read-only and returns a concise summary. `@general` has full tool access and can parallelize independent units of work.

      ### Code Intelligence

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

      ### Committing Code

      Git commit signing is required, but the location of the signing key is context dependent.

      - If the GIT_SIGNING_KEY environment variable is set, then use `git -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$GIT_SIGNING_KEY"`.
      - If the GIT_SIGNING_KEY environment variable is not set but the id_ed25519 SSH key exists, then use `git -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519"`.
      - If the GIT_SIGNING_KEY environment variable is not set and the id_ed25519 SSH key does not exist, then no signing key is available and you will need to ask the user for assistance when committing code.

      When making a commit, always add `Co-authored-by: OpenCode ($CURRENT_MODEL_IDENTIFIER) <noreply@opencode.ai>` as the *last* paragraph of the commit message. For example, if the GIT_SIGNING_KEY environment variable is not set, the id_ed25519 SSH key exists, the in-use model is MiniMax M3, and the desired commit message is "Added more cowbell", then the final commit command would look as follows:

      ```bash
      git -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" commit -m "Added more cowbell" -m "Co-authored-by: OpenCode (minimax-m3) <noreply@opencode.ai>"
      ```

      ## Communication Guidance

      IMPORTANT: Load the `simple-english` skill NOW for important communication guidelines.
    '';

    skills.simple-english = ./modules/simple-english/skills/simple-english;

    agents.code-review = ''
      ---
      description: Review code for security, quality, and best practices
      mode: subagent
      model: opencode-go/minimax-m3
      temperature: 0.2
      ---
      Review the code in this repository for security and best practices. DO NOT MAKE ANY CHANGES.

      Use LSP for code navigation whenever it is available (`goToDefinition`, `findReferences`, `workspaceSymbol`, `documentSymbol`, `hover`). Reserve grep, glob, and direct reads for text and configuration searches where LSP does not help.

      Focus on the following areas:

      - **Security:** Are there any business logic flaws or other patterns that could lead to potential security issues, either alone or in combination with other problematic code? Are all dependencies up to date? Are all secrets handled in a safe fashion? Are any configuration options that could lead to a weakened security posture properly documented?
      - **Code quality:** Does the code follow the accepted best practices of the language in which it is written? Is there dead code that can be removed? Is there duplicative code that can be reasonably combined into a single functional unit? Is the code written in a clear, modular fashion? Is the code written in an economical fashion? Is the code written in a way that is clear and as self-documenting as possible?
      - **Linter compliance:** Does the code under review pass the linters that the project declares as mandatory? Look for a project `AGENTS.md`, contributing guide, or similar document to find the names of any required linters, then run them over the code under review. Linter warnings and errors are project defects, not preferences, when the project declares linter compliance mandatory.
      - **Documentation quality:** Do comments accurately reflect the functionality of the code with which they are associated? Do important or significant blocks of code lack comments? Does documentation included in the repository accurately reflect the current state of the code base? Are there any obvious gaps in the included documentation?

      Results must be written to a document in the root of the working tree called CODE_REVIEW_RESULTS.md. Each finding is a Markdown todo item with one of the following severities as a label. The label is one of `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`. `CRITICAL` means a security flaw or correctness bug. `HIGH` means a likely bug or significant quality problem. `MEDIUM` means a style, performance, or maintainability issue. `LOW` means a minor suggestion or nit. The item body must describe the issue and recommend a remediation approach. If the file already exists, append the results to the end under a header with the date and time of the analysis to separate new results from those previously reported. The command `date "+%Y-%m-%d %H:%M"` outputs the current date and time for this purpose. Do not duplicate any findings that already exist.
    '';

    settings = {
      model = "opencode-go/minimax-m3";
      small_model = "opencode-go/deepseek-v4-flash";
      shell = "bash";
      # Shadow the built-in `general` and `explore` subagents to use a
      # cheaper but still capable model for the actual grind. Only `model`
      # is specified, so opencode's per-field merge preserves each
      # subagent's built-in prompt, description, and permissions —
      # shadowing only the model future-proofs us against changes to the
      # built-in prompts. The primary agent (orchestrator/planner) and
      # `@code-review` continue to use `opencode-go/minimax-m3`.
      # https://opencode.ai/docs/agents/#model
      agent = {
        general.model = "opencode-go/deepseek-v4-pro";
        explore.model = "opencode-go/deepseek-v4-pro";
      };
      # YOLO mode is intentional here: opencode is only ever deployed on
      # VMs without access to the host filesystem (`linux` target) or on
      # remote VMs hosted by Exe.dev (`exedev` and `hermes` targets).
      # The agent runs in approval-free mode, but has no path to a
      # filesystem that hasn't been purpose-built for it (and can be torn
      # down and rebuilt without any larger concerns). This is a harder
      # security boundary than approval prompts allow, by design — note
      # also that opencode is *not* installed on the `android` target
      # because that VM exposes `/sdcard` as a mount point.
      #
      permission = "allow";
      lsp = true;
      formatter = {
        # Defensive: opencode's default Nix formatter is nixfmt. We
        # prefer alejandra (configured below) for consistency with the
        # rest of the dotfiles repo and with Helix's auto-formatter.
        nixfmt = {
          disabled = true;
        };
        alejandra = {
          command = [
            "${pkgs.alejandra}/bin/alejandra"
            "--quiet"
            "$FILE"
          ];
          extensions = [".nix"];
        };
      };
      plugin = ["opencode-pty"];
    };
    tui = {
      theme = "gruvbox";
    };
  };
}
