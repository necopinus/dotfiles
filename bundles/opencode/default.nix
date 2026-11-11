{
  config,
  pkgs,
  ...
}: let
  localPkgs = {
    no-ai-slop = pkgs.callPackage ./pkgs/no-ai-slop {};
    simple-english = pkgs.callPackage ./pkgs/simple-english {};
    ephemeral-git = pkgs.callPackage ../git/pkgs/ephemeral-git.nix {};
  };
in {
  programs.opencode = {
    enable = true;

    extraPackages = with pkgs; [
      #### Helper tools ####
      localPkgs.ephemeral-git
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
      #biome # FIXME: build seems to be broken as of 2026-11-08
      dockerfile-language-server
      jdk
      nixd
      texlab
      ty
      yaml-language-server
    ];

    context = ./prompts/AGENTS.md;

    # home-manager accepts store paths here; each package vendors the
    # upstream skill under share/opencode/skills.
    #
    skills.no-ai-slop = "${localPkgs.no-ai-slop}/share/opencode/skills/no-ai-slop";
    skills.simple-english = "${localPkgs.simple-english}/share/opencode/skills/simple-english";

    # context-mode's companion skills (usage guides for its MCP tools).
    #
    skills.context-mode = "${pkgs.context-mode}/lib/context-mode/skills/context-mode";
    skills.ctx-doctor = "${pkgs.context-mode}/lib/context-mode/skills/ctx-doctor";
    #skills.ctx-index = "${pkgs.context-mode}/lib/context-mode/skills/ctx-index"; # v1.0.152+
    skills.ctx-insight = "${pkgs.context-mode}/lib/context-mode/skills/ctx-insight";
    skills.ctx-purge = "${pkgs.context-mode}/lib/context-mode/skills/ctx-purge";
    #skills.ctx-search = "${pkgs.context-mode}/lib/context-mode/skills/ctx-search"; # v1.0.152+
    skills.ctx-stats = "${pkgs.context-mode}/lib/context-mode/skills/ctx-stats";
    skills.ctx-upgrade = "${pkgs.context-mode}/lib/context-mode/skills/ctx-upgrade";

    # NOTE: We use a different model here than the main orchestrator or
    # subagent in order to get a "fresh perspective" during code review
    #
    agents.code-review = ./prompts/code-review.md;

    mutableSettings = true;
    # The config schema references models.dev, which check-jsonschema cannot
    # fetch in the Nix build sandbox. The CLI schema is local and is validated.
    validateFiles = {
      config = false;
      cli = true;
    };
    settings = {
      model = "opencode-go/kimi-k3.1-pro";
      small_model = "opencode-go/deepseek-v4.1-flash";
      shell = "bash";
      # Shadow the built-in `general` and `explore` subagents to use a
      # cheaper but still capable model for the actual grind. Only `model`
      # is specified, so opencode's per-field merge preserves each
      # subagent's built-in prompt, description, and permissions —
      # shadowing only the model future-proofs us against changes to the
      # built-in prompts. The primary agent (orchestrator/planner) and
      # `@code-review` continue to use more powerful models.
      # https://opencode.ai/docs/agents/#model
      agent = {
        general.model = "opencode-go/deepseek-v4.1-flash";
        explore.model = "opencode-go/deepseek-v4.1-flash";
      };
      # YOLO mode is intentional here: opencode is only ever deployed on
      # remote VMs hosted by Exe.dev (`exedev` and `hermes` targets).
      # The agent runs in approval-free mode, but has no path to a
      # filesystem that hasn't been purpose-built for it (and can be torn
      # down and rebuilt without any larger concerns). This is a harder
      # security boundary than approval prompts allow, by design.
      #
      permission = "allow";
      lsp = true;
      mcp = {
        context-mode = {
          type = "local";
          command = ["${pkgs.context-mode}/bin/context-mode"];
          enabled = true;
        };
        nix = {
          type = "local";
          command = ["${pkgs.mcp-nixos}/bin/mcp-nixos"];
          enabled = true;
        };
      };
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
    };
    cli = {
      theme = {
        name = "gruvbox";
        mode = "light";
      };
      plugins = ["${config.programs.herdr.package}/share/herdr/integrations/opencode/herdr-tui-session.js"];
    };
  };

  # Launch OpenCode in stand-alone mode to prevent surprises
  #
  xdg.configFile."bash/rc.d/opencode.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias opencode="${config.programs.opencode.package}/bin/opencode --standalone"
    '';
  };
  xdg.configFile."zsh/rc.d/opencode.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias opencode="${config.programs.opencode.package}/bin/opencode --standalone"
    '';
  };
  xdg.configFile."fish/rc.d/opencode.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias opencode "${config.programs.opencode.package}/bin/opencode --standalone"
    '';
  };
}
