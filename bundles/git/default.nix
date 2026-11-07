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
in {
  programs.git = {
    enable = true;
    package = null; # Use system git

    lfs.enable = true;

    settings = {
      core = {
        # Point git at each repo's .githooks/ directory. Repos without a
        # .githooks/ directory simply have no hooks (git's default hook
        # lookup is silent when a hook script is missing).
        hooksPath = ".githooks";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
      "gpg \"ssh\"" = {
        allowedSignersFile = ".allowed_signers";
      };
      "lfs \"customtransfer.xet\"" = {
        path = "${pkgs.git-xet}/bin/git-xet";
        args = "transfer";
        concurrent = true;
      };
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  # Make dependencies available on PATH
  #
  home.packages = [pkgs.proton-pass-cli] ++ hookPackages;

  # Fix `git log` pager issue on some systems
  #
  home.sessionVariables.PAGER = "less";

  # Wrap git to enable dynamically setting user.signingKey. The
  # core.hooksPath = ".githooks" setting above makes git pick up each
  # repo's .githooks/pre-commit automatically (repos without .githooks/
  # silently have no hooks).
  #
  xdg.configFile."bash/rc.d/git.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      git () {
        if [[ -n "$PORTABLE_PAT" ]]; then
          PORTABLE_DIR="$(mktemp -d)"
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli login
          PORTABLE_SSH_KEY="$(env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli ssh-agent load --vault-name Portable
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli logout
          rm -rf "$PORTABLE_DIR"
        else
          if ! pass-cli info &> /dev/null; then
            pass-cli login
          fi
          PORTABLE_SSH_KEY="$(pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
          pass-cli ssh-agent load --vault-name Portable
        fi

        env SSH_COMMAND="ssh -i /dev/null" $(which git) -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$PORTABLE_SSH_KEY" "$@"

        echo "$PORTABLE_SSH_KEY" | ssh-add -d -
      }
    '';
  };
  xdg.configFile."zsh/rc.d/git.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      git () {
        if [[ -n "$PORTABLE_PAT" ]]; then
          PORTABLE_DIR="$(mktemp -d)"
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli login
          PORTABLE_SSH_KEY="$(env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli ssh-agent load --vault-name Portable
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN="$PORTABLE_PAT" PROTON_PASS_SESSION_DIR="$PORTABLE_DIR" pass-cli logout
          rm -rf "$PORTABLE_DIR"
        else
          if ! pass-cli info &> /dev/null; then
            pass-cli login
          fi
          PORTABLE_SSH_KEY="$(pass-cli item view "pass://Portable/SSH :: Portable/Public key")"
          pass-cli ssh-agent load --vault-name Portable
        fi

        env SSH_COMMAND="ssh -i /dev/null" $(whence -p git) -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$PORTABLE_SSH_KEY" "$@"

        echo "$PORTABLE_SSH_KEY" | ssh-add -d -
      }
    '';
  };
  xdg.configFile."fish/rc.d/git.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      function git
        if test -n "$PORTABLE_PAT"
          set PORTABLE_DIR $(mktemp -d)
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN=$PORTABLE_PAT PROTON_PASS_SESSION_DIR=$PORTABLE_DIR pass-cli login
          set PORTABLE_SSH_KEY $(env PROTON_PASS_PERSONAL_ACCESS_TOKEN=$PORTABLE_PAT PROTON_PASS_SESSION_DIR=$PORTABLE_DIR pass-cli item view "pass://Portable/SSH :: Portable/Public key")
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN=$PORTABLE_PAT PROTON_PASS_SESSION_DIR=$PORTABLE_DIR pass-cli ssh-agent load --vault-name Portable
          env PROTON_PASS_PERSONAL_ACCESS_TOKEN=$PORTABLE_PAT PROTON_PASS_SESSION_DIR=$PORTABLE_DIR pass-cli logout
          rm -rf $PORTABLE_DIR
        else
          pass-cli info &> /dev/null
          if test $status -ne 0
            pass-cli login
          end
          set PORTABLE_SSH_KEY $(pass-cli item view "pass://Portable/SSH :: Portable/Public key")
          pass-cli ssh-agent load --vault-name Portable
        end

        set GIT_EXEC $(which git)

        env SSH_COMMAND="ssh -i /dev/null" $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$PORTABLE_SSH_KEY" $argv

        echo $PORTABLE_SSH_KEY | ssh-add -d -
      end
    '';
  };
}
