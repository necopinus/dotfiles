{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    antigravity-cli = pkgs.callPackage ./pkgs/antigravity-cli.nix {inherit llm-agents;};
  };
in {
  programs.antigravity-cli = {
    enable = true;
    package = localPkgs.antigravity-cli;

    context.GEMINI = ''
      ## Coding Guidance

      If you have not already developed a plan, do so before making any changes, no matter how simple the task. Never shy away from asking clarifying questions.

      **When writing code, prioritize readability, simplicity, and security.** Alway include comments that explain the purpose and functionality of significant code blocks in plain language. Make sure that variables have descriptive names, and prefer straight-forward solutions to "clever" approaches that are less intelligble. Always use secure coding practices, even if doing so results in slightly slower or less efficient code. If the project is large enough to span multiple files, it is large enough to use unit tests for input/output functionality.

      **Write code, comments, and documentation so that a future version of yourself will be able to understand this project quickly and with minimal tokens.**

      Always run a linter to check your code for obvious security problems. The following linters are already available:

      - `shellcheck` (Bash-compatible shell code)
      - `rslint` (JavaScript and TypeScript)
      - `ruff` (Python)

      If you need an additional linter, you should ask the user to install one. Never disable linter checks without first receiving approval from the user. **The project is not complete until all warnings and errors have been resolved.**
    '';

    settings = {
      artifactReviewPolicy = "agent-decides";
      notifications = true;
      showFeedbackSurvey = false;
      useG1Credits = true;
      context.fileName = [
        "GEMINI.md"
        "AGENTS.md"
        "CLAUDE.md"
      ];
    };
  };

  # YOLO mode by default
  #
  # We add this flag as an alias, rather than within the `agy` wrapper,
  # so that we can still call Antigravity without this flag when desired
  # (by directly calling ~/.nix-profile/bin/agy)
  #
  xdg.configFile."bash/rc.d/antigravity.sh" = {
    enable = config.programs.bash.enable && pkgs.stdenv.isLinux;
    text = ''
      alias agy="${config.programs.antigravity-cli.package}/bin/agy --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."zsh/rc.d/antigravity.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.isLinux;
    text = ''
      alias agy="${config.programs.antigravity-cli.package}/bin/agy --dangerously-skip-permissions"
    '';
  };
  xdg.configFile."fish/rc.d/antigravity.fish" = {
    enable = config.programs.fish.enable && pkgs.stdenv.isLinux;
    text = ''
      alias agy "${config.programs.antigravity-cli.package}/bin/agy --dangerously-skip-permissions"
    '';
  };
}
