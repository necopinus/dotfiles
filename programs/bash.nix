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

      # Check for SANDBOXED_* paths and replace computed paths with
      # these values if found (this works around the chicken-and-egg
      # problem where paths passed in during sandboxing may be wiped
      # out during init and cannot be reconstructed from within the
      # sandbox due to restrictions)
      #
      # IMPORTANT: Keep this block in sync with the SANDBOXED_* paths
      # set by the `nono` wrapper function!
      #
      if [ -n "$SANDBOXED_PATH" ]; then
        export PATH="$SANDBOXED_PATH"
        unset SANDBOXED_PATH
      fi
      if [ -n "$SANDBOXED_MANPATH" ]; then
        export MANPATH="$SANDBOXED_MANPATH"
        unset SANDBOXED_MANPATH
      fi
      if [ -n "$SANDBOXED_TERMINFO_DIRS" ]; then
        export TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS"
        unset SANDBOXED_TERMINFO_DIRS
      fi
      if [ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]; then
        export XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS"
        unset SANDBOXED_XDG_CONFIG_DIRS
      fi
      if [ -n "$SANDBOXED_XDG_DATA_DIRS" ]; then
        export XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS"
        unset SANDBOXED_XDG_DATA_DIRS
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      export SHELL="$(which bash)"
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        fi
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
      #### BEGIN: Repeat from ~/.profile to catch non-login shells ####

      # Set OS type
      #
      OS="$(uname -s)"

      # Check for SANDBOXED_* paths and replace computed paths with
      # these values if found (this works around the chicken-and-egg
      # problem where paths passed in during sandboxing may be wiped
      # out during init and cannot be reconstructed from within the
      # sandbox due to restrictions)
      #
      # IMPORTANT: Keep this block in sync with the SANDBOXED_* paths
      # set by the `nono` wrapper function!
      #
      if [[ -n "$SANDBOXED_PATH" ]]; then
        export PATH="$SANDBOXED_PATH"
        unset SANDBOXED_PATH
      fi
      if [[ -n "$SANDBOXED_MANPATH" ]]; then
        export MANPATH="$SANDBOXED_MANPATH"
        unset SANDBOXED_MANPATH
      fi
      if [[ -n "$SANDBOXED_TERMINFO_DIRS" ]]; then
        export TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS"
        unset SANDBOXED_TERMINFO_DIRS
      fi
      if [[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]]; then
        export XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS"
        unset SANDBOXED_XDG_CONFIG_DIRS
      fi
      if [[ -n "$SANDBOXED_XDG_DATA_DIRS" ]]; then
        export XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS"
        unset SANDBOXED_XDG_DATA_DIRS
      fi

      # Set SHELL to the correct value
      #
      export SHELL="$(which bash)"
      if shopt -q login_shell; then
        if [[ -x "$(realpath /bin)"/bash ]]; then
          export SHELL="$(realpath /bin)"/bash
        elif [[ -x "$(realpath /usr/bin)"/bash ]]; then
          export SHELL="$(realpath /usr/bin)"/bash
        fi
      fi

      ##### END: Repeat from ~/.profile to catch non-login shells #####

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
      # https://github.com/sharkdp/bat/issues/1433#issuecomment-3298530339
      #
      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | bat -p -lman'"

      # Colorful directory listsings
      #
      eval $(dircolors --sh)

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
      alias sudo="/usr/bin/sudo -E"
      alias top="$(which btm) --basic"
      alias vi="$(which "$EDITOR")"
      alias vim="$(which "$EDITOR")"
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

      # Wrap Claude Code in the Nono sandbox, but only if not called
      # recursively (to avoid sandboxing the sandbox)
      #
      # Note that we have to resolve (potentially) critical paths in
      # the environment, as nono will not follow home-manager's
      # symlinks without making all of $HOME readable
      #
      function nono {
        SEP=""
        SANDBOXED_PATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_PATH="$SANDBOXED_PATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${PATH:+"''${PATH}:"}"

        SEP=""
        SANDBOXED_MANPATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_MANPATH="$SANDBOXED_MANPATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${MANPATH:+"''${MANPATH}:"}"

        SEP=""
        SANDBOXED_TERMINFO_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${TERMINFO_DIRS:+"''${TERMINFO_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_CONFIG_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_DATA_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

        export SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS

        env -S \
          $([[ -z "$SANDBOXED_PATH" ]] && echo -n "-u PATH") \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_PATH" ]] && echo -n "PATH=\"$SANDBOXED_PATH\"") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          "$(realpath "$(which nono)")" "$@"

        unset SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS
      }
      function claude {
        CLAUDE_CODE_EXEC="$(realpath "$(which claude)")"

        if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]] || [[ -n "$NONO_CAP_FILE" ]]; then
          "$CLAUDE_CODE_EXEC" "$@"
        else
          # Note that all of the allow/allow-file/read/read-file lines
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
            $([[ -d "$XDG_CACHE_HOME"/starship ]] && echo -n "--allow $XDG_CACHE_HOME/starship") \
            $([[ -d "$XDG_CACHE_HOME"/uv ]] && echo -n "--allow $XDG_CACHE_HOME/uv") \
            $([[ -d "$XDG_CONFIG_HOME"/go ]] && echo -n "--allow $XDG_CONFIG_HOME/go") \
            $([[ -d "$XDG_CONFIG_HOME"/zsh ]] && echo -n "--allow $XDG_CONFIG_HOME/zsh") \
            $([[ -d "$XDG_DATA_HOME"/fish ]] && echo -n "--allow $XDG_DATA_HOME/fish") \
            $([[ -d "$XDG_DATA_HOME"/pnpm ]] && echo -n "--allow $XDG_DATA_HOME/pnpm") \
            $([[ -d "$XDG_STATE_HOME"/pnpm ]] && echo -n "--allow $XDG_STATE_HOME/pnpm") \
            $([[ -d /tmp ]] && echo -n "--allow /tmp") \
            $([[ -d /var/folders ]] && echo -n "--allow /var/folders") \
            $([[ -e /dev/null ]] && echo -n "--allow-file /dev/null") \
            $([[ -d "$HOME"/.ssh ]] && echo -n "--read $HOME/.ssh") \
            $([[ -d "$XDG_CACHE_HOME"/bat ]] && echo -n "--read $XDG_CACHE_HOME/bat") \
            $([[ -d "$XDG_CONFIG_HOME"/fish ]] && echo -n "--read $XDG_CONFIG_HOME/fish") \
            $([[ -d "$XDG_CONFIG_HOME"/starship ]] && echo -n "--read $XDG_CONFIG_HOME/starship") \
            $([[ -d /etc/skel ]] && echo -n "--read /etc/skel") \
            $([[ -d /nix ]] && echo -n "--read /nix") \
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
