{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = null; # Use system git

    lfs.enable = true;

    settings = {
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
      "gpg \"ssh\"" = {
        allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };
      "lfs \"customtransfer.xet\"" = {
        path = "${pkgs.git-xet}/bin/git-xet";
        args = "transfer";
        concurrent = "true";
      };
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  # Fix `git log` pager issue on some systems
  #
  home.sessionVariables.PAGER = "less";

  # Wrap git to enable dynamically setting user.signingKey
  #
  xdg.configFile."bash/rc.d/git.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      git () {
        GIT_EXEC="$(which git)"

        if [[ -n "$GIT_SIGNING_KEY" ]]; then
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$GIT_SIGNING_KEY" "$@"
        elif [[ -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]]; then
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" "$@"
        else
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" "$@"
        fi
      }
    '';
  };
  xdg.configFile."zsh/rc.d/git.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      git () {
        GIT_EXEC="$(whence -p git)"

        if [[ -n "$GIT_SIGNING_KEY" ]]; then
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$GIT_SIGNING_KEY" "$@"
        elif [[ -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]]; then
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" "$@"
        else
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" "$@"
        fi
      }
    '';
  };
  xdg.configFile."fish/rc.d/git.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      function git
        set GIT_EXEC $(which git)

        if test -n "$GIT_SIGNING_KEY"
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="key::$GIT_SIGNING_KEY" $argv
        else if test -f "${config.home.homeDirectory}/.ssh/id_ed25519"
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" $argv
        else
          $GIT_EXEC -c user.name="Nathan Acks" -c user.email="nathan.acks@cardboard-iguana.com" $argv
        end
      end
    '';
  };
}
