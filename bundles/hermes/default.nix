{
  pkgs,
  config,
  ...
}: let
  localPkgs = {
    inaba = pkgs.callPackage ./pkgs/inaba.nix {};
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
    mcplogic = pkgs.callPackage ./pkgs/mcplogic {};
    no-ai-slop = pkgs.callPackage ../opencode/pkgs/no-ai-slop {};
    scimath-mcp = pkgs.callPackage ./pkgs/scimath-mcp {};
    simple-english = pkgs.callPackage ../opencode/pkgs/simple-english {};
    wiki-mcp = pkgs.callPackage ./pkgs/wiki-mcp {};
  };

  # Values used by the Hermes user-level systemd units below. Derived from
  # home-manager's own home config rather than hardcoded, so the bundle stays
  # portable across hosts/usernames.
  #
  hermesHome = "${config.home.homeDirectory}/.hermes";
  venv = "${hermesHome}/hermes-agent/venv";

  # PATH for the Hermes services. Mirrors the system-level units but built
  # from config.home.homeDirectory.
  #
  servicePath = builtins.concatStringsSep ":" [
    "${venv}/bin"
    "${hermesHome}/hermes-agent/node_modules/.bin"
    "${hermesHome}/node/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "/bin"
    "/usr/bin"
    "/sbin"
    "/usr/sbin"
    "/exe.dev/bin"
    "/usr/local/bin"
  ];

  # Environment shared by all three Hermes services. home-manager's systemd
  # module wants Environment as a list of "KEY=value" strings.
  #
  commonEnv = [
    "HOME=${config.home.homeDirectory}"
    "USER=${config.home.username}"
    "LOGNAME=${config.home.username}"
    "PATH=${servicePath}"
    "VIRTUAL_ENV=${venv}"
    "HERMES_HOME=${hermesHome}"
    "HERMES_SUPERVISED_CHILD=1"
  ];
in {
  home.packages = with pkgs; [
    #### Convenience wrapper ####
    localPkgs.inaba

    #### Additional deps ####
    agent-browser
    clang
    playwright-test
    tirith

    #### Tools ####
    lmodern # Needed by texliveMedium
    pandoc
    python3Packages.jsonschema
    python3Packages.weasyprint
    texliveMedium

    #### Skills ####
    localPkgs.no-ai-slop
    localPkgs.simple-english

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
    localPkgs.mcplogic
    localPkgs.scimath-mcp
    localPkgs.wiki-mcp
    markitdown-mcp
    mcp-nixos
  ];

  programs.npm.enable = true; # Just use Nix to avoid NodeJs package conflicts
  programs.ripgrep.enable = pkgs.stdenv.hostPlatform.isDarwin; # Installed at the system level on Linux
  programs.uv.enable = true;

  # Hermes makes on-demand commits to a small set of repos using a
  # tightly-scoped access token stored in the credential store. Every
  # other system uses SSH keys exclusively, so the helper config lives
  # here rather than in bundles/git (which is shared by all systems).
  #
  programs.git.settings = {
    credential = {
      helper = "store";
      useHttpPath = true;
    };
  };

  # Hermes long-running services as systemd --user units.
  #
  # Running them under the user manager gives the gateway a user D-Bus
  # session, which the restart-safe cron worker dispatch
  # (tools/process_registry.py) requires to spawn agentic cron workers
  # via `systemd-run --user --scope`. A system-level topology has no
  # user bus, so every agentic cron job failed at dispatch.
  #
  # Requires `sudo loginctl enable-linger $USER` so the user manager
  # (and these units) start at boot without any login.
  #
  systemd.user.services = {
    hermes-gateway = {
      Unit = {
        Description = "Hermes Agent Gateway - Messaging Platform Integration";
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        ExecStart = "${venv}/bin/python -m hermes_cli.main gateway run";
        WorkingDirectory = hermesHome;
        Environment = commonEnv;
        Restart = "always";
        RestartSec = 5;
        RestartForceExitStatus = 75;
        SuccessExitStatus = 75;
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        ExecStopPost = "-${venv}/bin/python -m gateway.cgroup_cleanup";
        TimeoutStopSec = 90;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = ["default.target"];
    };

    hermes-dashboard = {
      Unit = {
        Description = "Hermes Agent Dashboard - Online Portal";
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        ExecStart = "${venv}/bin/python -m hermes_cli.main dashboard --host 0.0.0.0 --no-open";
        WorkingDirectory = hermesHome;
        Environment = commonEnv;
        Restart = "always";
        RestartSec = 5;
        RestartForceExitStatus = 75;
        SuccessExitStatus = 75;
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        TimeoutStopSec = 90;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = ["default.target"];
    };

    hermes-relay = {
      Unit = {
        Description = "Hermes-Relay Server - WSS Bridge for Android App";
        Documentation = "https://github.com/Codename-11/hermes-relay/blob/main/docs/relay-server.md";
        StartLimitIntervalSec = 600;
        StartLimitBurst = 5;
      };
      Service = {
        Type = "simple";
        ExecStart = "${venv}/bin/python -m hermes_cli.main relay start --no-ssl --log-level INFO";
        WorkingDirectory = "${hermesHome}/hermes-relay";
        Environment = commonEnv;
        Restart = "on-failure";
        RestartSec = 30;
        RestartForceExitStatus = 75;
        SuccessExitStatus = 75;
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        TimeoutStopSec = 90;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
