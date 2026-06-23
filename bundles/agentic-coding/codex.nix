{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    codex = pkgs.callPackage ./pkgs/codex.nix {inherit llm-agents;};
  };
in {
  programs.codex = {
    enable = true;
    package = localPkgs.codex;

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

      ## Committing Code

      Git commit signing is required, but the location of the signing key is context dependent.

      - If the GIT_SIGNING_KEY environment variable is set, then use `git -c user.signingKey="$GIT_SIGNING_KEY"`.
      - If the GIT_SIGNING_KEY environment variable is not set but the id_ed25519 SSH key exists, then use `git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519"`.
      - If the GIT_SIGNING_KEY environment variable is not set and the id_ed25519 SSH key does not exist, then no signing key is available and you will need to ask the user for assistance when committing code.
    '';

    settings = {
      tui = {
        terminal_title = [
          "activity"
          "project-name"
          "run-state"
        ];
        status_line = [
          "model-with-reasoning"
          "current-dir"
          "git-branch"
          "run-state"
          "context-remaining"
          "five-hour-limit"
          "weekly-limit"
          "task-progress"
        ];
        status_line_use_colors = true;
        theme = "gruvbox-light";
      };
      features = {
        memories = true;
        terminal_resize_reflow = true;
      };
      "plugins.\"codex-security@openai-curated\"".enabled = true;
      model_reasoning_effort = "high";
      project_doc_fallback_filenames = [
        "CLAUDE.md"
        "GEMINI.md"
      ];
    };
  };

  # YOLO mode by default
  #
  # We add this flag as an alias, rather than within the `codex`
  # wrapper, so that we can still call Codex without this flag when
  # desired (by directly calling ~/.nix-profile/bin/codex)
  #
  xdg.configFile."bash/rc.d/codex.sh" = {
    enable = config.programs.bash.enable && pkgs.stdenv.isLinux;
    text = ''
      alias codex="${config.programs.codex.package}/bin/codex --yolo"
    '';
  };
  xdg.configFile."zsh/rc.d/codex.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.isLinux;
    text = ''
      alias codex="${config.programs.codex.package}/bin/codex --yolo"
    '';
  };
  xdg.configFile."fish/rc.d/codex.fish" = {
    enable = config.programs.fish.enable && pkgs.stdenv.isLinux;
    text = ''
      alias codex "${config.programs.codex.package}/bin/codex --yolo"
    '';
  };
}
