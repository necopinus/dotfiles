{
  config,
  pkgs,
  ...
}: let
  # Linters / formatters / scanners required by various per-repo
  # pre-commit hooks
  hookPackages = with pkgs; [
    #### Nix ####
    alejandra
    statix
    deadnix

    #### Shell ####
    shellcheck
    shfmt

    #### YAML ####
    yamllint

    #### Python ####
    ruff

    #### Markdown ####
    markdownlint-cli2

    #### Secret scanning ####
    betterleaks
  ];

  ephemeralGit = pkgs.callPackage ./pkgs/ephemeral-git.nix {};
in {
  programs.git = {
    enable = true;
    package = null; # Use system git

    # Disable repository-provided hooks by default. Conditional includes
    # below override this only for the trusted repository roots and this
    # dotfiles repository.
    #
    settings = {
      core.hooksPath = "/dev/null";
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
      "gpg \"ssh\"" = {
        allowedSignersFile = ".allowed_signers";
      };
    };

    includes =
      map (condition: {
        inherit condition;
        contents.core.hooksPath = ".githooks";
      }) [
        "gitdir:~/Projects/"
        "gitdir:~/src/"
        "gitdir:~/workspace/"
        "gitdir:~/.config/nix/.git"
      ];

    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  # Make dependencies available on PATH. The ephemeral helpers are referenced
  # by absolute store path and deliberately are not installed on PATH.
  #
  home.packages = [pkgs.proton-pass-cli] ++ hookPackages;

  # Fix `git log` pager issue on some systems
  #
  home.sessionVariables.PAGER = "${config.programs.bat.package}/bin/bat";

  # Use the external helper for every git invocation. It bypasses Proton Pass
  # for local commands and manages temporary agents for commands that need
  # authentication or signing.
  #
  xdg.configFile."bash/rc.d/git.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias git="${ephemeralGit}/bin/ephemeral-git"
    '';
  };
  xdg.configFile."zsh/rc.d/git.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias git="${ephemeralGit}/bin/ephemeral-git"
    '';
  };
  xdg.configFile."fish/rc.d/git.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias git "${ephemeralGit}/bin/ephemeral-git"
    '';
  };
}
