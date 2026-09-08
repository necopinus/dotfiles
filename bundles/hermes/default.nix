{
  pkgs,
  config,
  ...
}: let
  localPkgs = {
    inaba = pkgs.callPackage ./pkgs/inaba.nix {};
    pyright = pkgs.callPackage ./pkgs/pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pkgs/pyright-langserver.nix {};
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
  ];
in {
  # TODO: Remove this fix once https://github.com/NixOS/nixpkgs/pull/545267
  # is live in nixpkgs-unstable
  #
  imports = [
    ./fixes/pandas-stubs-20260729.nix
  ];

  home.packages = with pkgs; [
    #### Convenience wrapper ####
    localPkgs.inaba

    #### Additional deps ####
    agent-browser
    playwright-test
    tirith

    #### Tools ####
    pandoc
    python3Packages.jsonschema
    python3Packages.weasyprint

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
    markitdown-mcp
    mcp-nixos
    officecli
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
      usHttpPath = true;
    };
  };

  # Convenience aliases
  #
  # NOTE: We DON'T prefix 'npx' here, as we want to make sure to use the
  # same version of npx/npm/node as Hermes (this lives in ~/.local/bin,
  # and is inserted into the PATH before ~/.nix-profile/bin)
  #
  xdg.configFile."bash/rc.d/hermes.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."zsh/rc.d/hermes.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
  };
  xdg.configFile."fish/rc.d/hermes.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias ob="npx --package=obsidian-headless --yes -- ob"
    '';
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
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        ExecStopPost = "-${venv}/bin/python -m gateway.cgroup_cleanup";
        TimeoutStopSec = 60;
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
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        TimeoutStopSec = 60;
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
        RestartPreventExitStatus = 78;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        ExecReload = "/bin/kill -USR1 $MAINPID";
        TimeoutStopSec = 60;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
