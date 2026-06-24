{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  localPkgs = {
    antigravity-cli = pkgs.callPackage ./pkgs/antigravity-cli.nix {};
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
    ];

  programs.antigravity-cli = {
    enable = true;

    package =
      if pkgs.stdenv.isLinux
      then llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      else localPkgs.antigravity-cli;

    context.GEMINI = ''
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

      - If the GIT_SIGNING_KEY environment variable is set, then use `git -c user.signingKey="key::$GIT_SIGNING_KEY"`.
      - If the GIT_SIGNING_KEY environment variable is not set but the id_ed25519 SSH key exists, then use `git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519"`.
      - If the GIT_SIGNING_KEY environment variable is not set and the id_ed25519 SSH key does not exist, then no signing key is available and you will need to ask the user for assistance when committing code.
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
  # We add this flag as an alias so that we can still call Antigravity
  # without this flag when desired (by directly calling
  # ~/.nix-profile/bin/agy)
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
