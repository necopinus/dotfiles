{pkgs, ...}: {
  programs.bash = {
    enable = true;

    # ~/.profile
    #
    sessionVariables = {
      BAT_THEME = "ansi";
      DELTA_FEATURES = "+generic-dark-theme";
    };

    profileExtra = ''
      # Set OS type
      #
      OS="$(uname -s)"

      # Load system defaults if they exist
      #
      if [ -n "$BASH" ]; then
        if [ -f /etc/skel/.bash_profile ]; then
          . /etc/skel/.bash_profile
        fi
      else
        if [ -f /etc/skel/.profile ]; then
          . /etc/skel/.profile
        fi
      fi

      # Make sure that Nix is set up
      #
      if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && [ -z "$__HM_SESS_VARS_SOURCED" ]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Load $XDG_CONFIG_HOME/user-dirs.dirs when applicable
      #
      if [ "$OS" == "Darwin" ] && [ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
        eval "$(cat "$XDG_CONFIG_HOME/user-dirs.dirs" | sed "s/^XDG_/export XDG_/")"
      fi

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [ -d /opt/homebrew/bin ]; then
        export PATH="$PATH:/opt/homebrew/bin"
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        else
          export SHELL="$(which bash)"
        fi
      else
        export SHELL="$(which bash)"
      fi
    '';

    # ~/.bash_profile sources ~/.profile and then ~/.bashrc

    # ~/.bashrc
    #
    bashrcExtra = ''
      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.bashrc ]]; then
        source /etc/skel/.bashrc
      fi

      # Make sure that Nix is set up
      #
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';

    historyControl = ["erasedups"];
    shellOptions = ["histappend"];
    enableCompletion = true;

    initExtra = ''
      # Set OS type
      #
      OS="$(uname -s)"

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        else
          export SHELL="$(which bash)"
        fi
      else
        export SHELL="$(which bash)"
      fi

      # Start ssh-agent, if necessary
      #
      #   https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
      #
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        if [[ -f "$HOME"/.ssh/agent.env ]]; then
          source "$HOME"/.ssh/agent.env
        fi
        if [[ -z "$SSH_AGENT_PID" ]] || [[ $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0 ]]; then
          if [[ ! -d "$HOME"/.ssh ]]; then
            mkdir -p "$HOME"/.ssh
          fi
          ssh-agent | sed '/^echo/d' > "$HOME"/.ssh/agent.env
          source "$HOME"/.ssh/agent.env
        fi
      fi

      # Colorize man pages with batman
      #
      eval "$(batman --export-env)"

      # Convenience aliases, unfortunately much too complex to set up
      # directly using home-manager's programs.bash.shellAliases
      #
      alias :e="$(which "$EDITOR")"
      alias :q=exit
      alias cat="$(which bat) -pp"
      alias diff="$(which delta)"
      alias glow="$(which glow) -s dark"
      alias htop="$(which btm) --basic"
      alias imgcat="$(which chafa)"
      alias jq="$(which jaq)"
      alias la="$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long --all"
      alias less="$(which bat)"
      alias ll="$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long"
      alias ls="$(which eza) --classify=auto --color=auto --group-directories-first --git --group"
      alias more="$(which bat)"
      alias nvim="$(which "$EDITOR")"
      alias prettycat="$(which prettybat)"
      alias rg="$(which batgrep)"
      alias sudo="/usr/bin/sudo -E"
      alias top="$(which btm) --basic"
      alias vi="$(which "$EDITOR")"
      alias vim="$(which "$EDITOR")"
      alias watch="$(which batwatch)"
      alias yq="$(which jaq)"

      # Alias LXQt session startup
      #
      if [[ "$OS" == "Linux" ]]; then
        alias start-desktop="$(which startlxqtwayland)"
        alias startlxqt="$(which startlxqtwayland)"
      fi

      # The Android Debian VM is surprisingly fragile, so we want to
      # do a shutdown rather than just exiting the last session
      #
      if [[ "$OS" == "Linux" ]]; then
        alias shutdown="/usr/bin/sudo /sbin/shutdown -h now"
      fi

      # Wrap man/batman to supress readlink errors
      #
      function man {
        MAN_EXEC="$(which man)"
        $MAN_EXEC "$@" 2> /dev/null
      }
      function batman {
        BATMAN_EXEC="$(which batman)"
        $BATMAN_EXEC "$@" 2> /dev/null
      }

      # Wrap Claude Code in the Nono sandbox, but only if not called
      # recursively (to avoid sandboxing the sandbox)
      #
      # Note that we have to resolve (potentially) critical paths in
      # the environment, as nono will not follow home-manager's
      # symlinks without making all of $HOME readable
      #
      function nono {
        SEP=""
        NEW_PATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            NEW_PATH="$NEW_PATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${PATH:+"''${PATH}:"}"

        SEP=""
        NEW_MANPATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            NEW_MANPATH="$NEW_MANPATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${MANPATH:+"''${MANPATH}:"}"

        SEP=""
        NEW_XDG_CONFIG_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            NEW_XDG_CONFIG_DIRS="$NEW_XDG_CONFIG_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

        SEP=""
        NEW_XDG_DATA_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            NEW_XDG_DATA_DIRS="$NEW_XDG_DATA_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

        env -S \
          $([[ -z "$NEW_PATH" ]] && echo -n "-u PATH") \
          $([[ -z "$NEW_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$NEW_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$NEW_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$NEW_PATH" ]] && echo -n "PATH=\"$NEW_PATH\"") \
          $([[ -n "$NEW_MANPATH" ]] && echo -n "MANPATH=\"$NEW_MANPATH\"") \
          $([[ -n "$NEW_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$NEW_XDG_CONFIG_DIRS\"") \
          $([[ -n "$NEW_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$NEW_XDG_DATA_DIRS\"") \
          CLAUDE_CODE_SHELL="$(realpath $(which bash))" \
          "$(realpath "$(which nono)")" "$@"
      }
      function claude {
        CLAUDE_CODE_EXEC="$(realpath "$(which claude)")"

        if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]]; then
          "$CLAUDE_CODE_EXEC" "$@"
        else
          # Note that all of the allow/allow-file/read/read-fil lines
          # (except for `--allow .`) can be removed when nono v0.5.0
          # hits nixpkgs-unstable
          #
          nono run \
            --profile claude-code \
            --allow . \
            $([[ -d "$XDG_CACHE_HOME"/fish ]] && echo -n "--allow $XDG_CACHE_HOME/fish") \
            $([[ -d "$XDG_CACHE_HOME"/go-build ]] && echo -n "--allow $XDG_CACHE_HOME/go-build") \
            $([[ -d "$XDG_CACHE_HOME"/pip ]] && echo -n "--allow $XDG_CACHE_HOME/pip") \
            $([[ -d "$XDG_CACHE_HOME"/pnpm ]] && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
            $([[ -d "$XDG_CACHE_HOME"/uv ]] && echo -n "--allow $XDG_CACHE_HOME/uv") \
            $([[ -d "$XDG_CONFIG_HOME"/fish ]] && echo -n "--allow $XDG_CONFIG_HOME/fish") \
            $([[ -d "$XDG_CONFIG_HOME"/go ]] && echo -n "--allow $XDG_CONFIG_HOME/go") \
            $([[ -d "$XDG_DATA_HOME"/delta ]] && echo -n "--allow $XDG_DATA_HOME/delta") \
            $([[ -d "$XDG_DATA_HOME"/fish ]] && echo -n "--allow $XDG_DATA_HOME/fish") \
            $([[ -d "$XDG_DATA_HOME"/pnpm ]] && echo -n "--allow $XDG_DATA_HOME/pnpm") \
            $([[ -d "$XDG_STATE_HOME"/pnpm ]] && echo -n "--allow $XDG_STATE_HOME/pnpm") \
            $([[ -d /tmp ]] && echo -n "--allow /tmp") \
            $([[ -e /dev/null ]] && echo -n "--allow-file /dev/null") \
            $([[ -d "$HOME"/.ssh ]] && echo -n "--read $HOME/.ssh") \
            $([[ -d "$XDG_CACHE_HOME"/bat ]] && echo -n "--read $XDG_CACHE_HOME/bat") \
            $([[ -d "$XDG_CONFIG_HOME" ]] && echo -n "--read $XDG_CONFIG_HOME") \
            $([[ -d /etc/skel ]] && echo -n "--read /etc/skel") \
            $([[ -d /nix ]] && echo -n "--read /nix") \
            $([[ -d /usr/share ]] && echo -n "--read /usr/share") \
            $([[ -e "$HOME"/.bash_aliases ]] && echo -n "--read-file $HOME/.bash_aliases") \
            $([[ -e /etc/bashrc ]] && echo -n "--read-file /etc/bashrc") \
            -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
        fi
      }

      # Convenience function for launching graphical apps from the terminal
      #
      if [[ "$OS" == "Linux" ]]; then
        function xcv {
          nohup "$@" 2>/dev/null
        }
      fi

      # Hack to get Bash to more agressively save its history
      #
      #   https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
      #
      PROMPT_COMMAND+=( "history -a" )
    '';

    enableVteIntegration = pkgs.stdenv.isLinux;
  };
}
