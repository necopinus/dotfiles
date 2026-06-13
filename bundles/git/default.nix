{config, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "Nathan Acks";
        email = "nathan.acks@cardboard-iguana.com";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  # Wrap git to enable dynamically setting user.signingKey
  #
  xdg.configFile."bash/rc.d/git.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      git () {
        if [[ -n "$GIT_SIGNING_KEY" ]]; then
          ${config.programs.git.package}/bin/git -c user.signingKey="$GIT_SIGNING_KEY" "$@"
        elif [[ -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]]; then
          ${config.programs.git.package}/bin/git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" "$@"
        else
          ${config.programs.git.package}/bin/git "$@"
        fi
      }
    '';
  };
  xdg.configFile."zsh/rc.d/git.zsh" = {
    enable = config.programs.zsh.enable;
    text = ''
      git () {
        if [[ -n "$GIT_SIGNING_KEY" ]]; then
          ${config.programs.git.package}/bin/git -c user.signingKey="$GIT_SIGNING_KEY" "$@"
        elif [[ -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]]; then
          ${config.programs.git.package}/bin/git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" "$@"
        else
          ${config.programs.git.package}/bin/git "$@"
        fi
      }
    '';
  };
  xdg.configFile."fish/rc.d/git.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      function git
        if test -n "$GIT_SIGNING_KEY"
          ${config.programs.git.package}/bin/git -c user.signingKey="$GIT_SIGNING_KEY" $argv
        else if test -f "${config.home.homeDirectory}/.ssh/id_ed25519"
          ${config.programs.git.package}/bin/git -c user.signingKey="${config.home.homeDirectory}/.ssh/id_ed25519" $argv
        else
          ${config.programs.git.package}/bin/git $argv
        end
      end
    '';
  };
}
