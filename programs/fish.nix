{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    # Run early for all shells
    #
    shellInit = ''
      # Set OS type
      #
      set OS $(uname -s)

      # Make sure that Nix is set up
      #
      if test -d /run/current-system/sw/bin
        fish_add_path /run/current-system/sw/bin
      end
      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; and test -z "$__ETC_PROFILE_NIX_SOURCED"
        cat /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | ${pkgs.babelfish}/bin/babelfish | source
      end
      if test -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; and test -z "$__HM_SESS_VARS_SOURCED"
        cat $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if test -d /opt/homebrew/bin
        fish_add_path --append /opt/homebrew/bin
      end

      # Load $XDG_CONFIG_HOME/user-dirs.dirs when applicable
      #
      if test "$OS" = "Darwin"; and test -f "$XDG_CONFIG_HOME/user-dirs.dirs"
        cat $XDG_CONFIG_HOME/user-dirs.dirs | sed "s/^XDG_/export XDG_/" | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Check for SANDBOXED_* paths and replace computed paths with
      # these values if found (this works around the chicken-and-egg
      # problem where paths passed in during sandboxing may be wiped
      # out during init and cannot be reconstructed from within the
      # sandbox due to restrictions)
      #
      # IMPORTANT: Keep this block in sync with the SANDBOXED_* paths
      # set by the `nono` wrapper function!
      #
      if test -n "$SANDBOXED_PATH"
        set -x PATH $(string split : $SANDBOXED_PATH)
        set -e SANDBOXED_PATH
      end
      if test -n "$SANDBOXED_MANPATH"
        set -x MANPATH $SANDBOXED_MANPATH
        set -e SANDBOXED_MANPATH
      end
      if test -n "$SANDBOXED_TERMINFO_DIRS"
        set -x TERMINFO_DIRS $SANDBOXED_TERMINFO_DIRS
        set -e SANDBOXED_TERMINFO_DIRS
      end
      if test -n "$SANDBOXED_XDG_CONFIG_DIRS"
        set -x XDG_CONFIG_DIRS $SANDBOXED_XDG_CONFIG_DIRS
        set -e SANDBOXED_XDG_CONFIG_DIRS
      end
      if test -n "$SANDBOXED_XDG_DATA_DIRS"
        set -x XDG_DATA_DIRS $SANDBOXED_XDG_DATA_DIRS
        set -e SANDBOXED_XDG_DATA_DIRS
      end

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      set SHELL $(which fish)

      # Cargo-culted from Google's /usr/local/bin/enable_gfxstream on
      # 2025-12-09
      #
      if test -f /usr/share/vulkan/icd.d/gfxstream_vk_icd.json
        set -x MESA_LOADER_DRIVER_OVERRIDE "zink"
        set -x VK_ICD_FILENAMES "/usr/share/vulkan/icd.d/gfxstream_vk_icd.json"
        set -x MESA_VK_WSI_DEBUG "sw,linear"
        set -x XWAYLAND_NO_GLAMOR 1
        set -x LIBGL_KOPPER_DRI2 1
      end
    '';

    # If defined, run `loginShellInit` for login shells

    # Run for interactive shells
    #
    interactiveShellInit = ''
      # Start ssh-agent, if necessary
      #
      #   https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
      #
      if test -z "$SSH_AUTH_SOCK"
        if test -f $HOME/.ssh/agent.env
          cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
        end
        if test -z "$SSH_AGENT_PID"; or test $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0
          if test ! -d $HOME/.ssh
            mkdir -p $HOME/.ssh
          end
          ssh-agent | sed '/^echo/d' > $HOME/.ssh/agent.env
          cat $HOME/.ssh/agent.env | ${pkgs.babelfish}/bin/babelfish | source
        end
      end

      # Colorize man pages with batman
      #
      # https://github.com/sharkdp/bat/issues/1433#issuecomment-3298530339
      #
      set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g;s/.\\x08//g\" | bat -p -lman'"

      # Colorful directory listsings
      #
      eval (dircolors --csh)

      # Theme options
      #
      set -gx BAT_THEME "ansi" # TODO: Change to "gruvbox-light" once the Android Terminal supports custom themes
      set -gx DELTA_FEATURES "+ansi-dark" # TODO: Change to "+gruvbox-light" once the Android Terminal supports custom themes

      #tweak_fish_colors gruvbox-light-medium # TODO: Uncomment once the Android Terminal supports custom themes

      # Convenience aliases
      #
      # TODO: Add `--icons=auto` to all `eza` aliases once the Android Terminal supports custom fonts
      #
      alias :e "$(which $EDITOR)"
      alias :q exit
      alias cat "$(which bat) -pp"
      alias diff "$(which delta)"
      alias glow "$(which glow) -s dark" # TODO: Change to $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json once the Android Terminal supports custom themes
      alias htop "$(which btm) --basic"
      alias imgcat "$(which chafa)"
      alias jq "$(which jaq)"
      alias la "$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long --all"
      alias less "$(which bat)"
      alias ll "$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long"
      alias ls "$(which eza) --classify=auto --color=auto --group-directories-first --git --group"
      alias more "$(which bat)"
      alias nvim "$(which $EDITOR)"
      alias sudo "/usr/bin/sudo -E"
      alias top "$(which btm) --basic"
      alias vi "$(which $EDITOR)"
      alias vim "$(which $EDITOR)"
      alias yq "$(which jaq)"

      # Fix zeditor on macOS
      #
      if test "$OS" = "Darwin"
        if test -n "$(which zed)"
          if test -d /Applications/Zed.app
            alias zed "$(which zed) --zed /Applications/Zed.app"
            alias zeditor "$(which zed) --zed /Applications/Zed.app"
          else if test -d "$HOME/Applications/Home Manager Apps/Zed.app"
            alias zed "$(which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
            alias zeditor "$(which zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          end
        else if test -n "$(which zeditor)"
          if test -d /Applications/Zed.app
            alias zed "$(which zeditor) --zed /Applications/Zed.app"
            alias zeditor "$(which zeditor) --zed /Applications/Zed.app"
          else if test -d "$HOME/Applications/Home Manager Apps/Zed.app"
            alias zed "$(which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
            alias zeditor "$(which zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
          end
        end
      end

      # Suppress welcome message
      #
      set -g fish_greeting
    '';

    # If defined, run `shellInitLast` last for all shells

    functions =
      {
        # Additional theme/color tweaks
        #
        tweak_fish_colors = ''
          if test $argv = "gruvbox-light-medium"
            set -g fish_color_autosuggestion a89984
            set -g fish_color_cancel --bold red
            set -g fish_color_command --bold cyan
            set -g fish_color_comment 928374
            set -g fish_color_end d65d0e
            set -g fish_color_error --bold red
            set -g fish_color_escape --bold magenta
            set -g fish_color_keyword --bold blue
            set -g fish_color_normal normal
            set -g fish_color_operator --bold green
            set -g fish_color_param normal
            set -g fish_color_quote --bold yellow
            set -g fish_color_redirection normal
            set -g fish_color_search_match --background f9f5d7
            set -g fish_color_selection normal --background d5c4a1
          else if test $argv = "gruvbox-material-light-hard"
            set -g fish_color_autosuggestion a89984
            set -g fish_color_cancel red
            set -g fish_color_command cyan
            set -g fish_color_comment 928374
            set -g fish_color_end c35e0a
            set -g fish_color_error red
            set -g fish_color_escape magenta
            set -g fish_color_keyword blue
            set -g fish_color_normal normal
            set -g fish_color_operator green
            set -g fish_color_param normal
            set -g fish_color_quote yellow
            set -g fish_color_redirection normal
            set -g fish_color_search_match --background f9eabf
            set -g fish_color_selection normal --background f2e5bc
          end
        '';

        # Wrap Claude Code in the Nono sandbox, but only if not called
        # recursively (to avoid sandboxing the sandbox)
        #
        # Note that we have to resolve (potentially) critical paths in
        # the environment, as nono will not follow home-manager's
        # symlinks without making all of $HOME readable
        #
        nono = ''
          set NONO_EXEC $(realpath $(which nono))

          set SEP ""
          set SANDBOXED_PATH ""
          for DIR in $(string split : $(string join : $PATH))
            if test -d $DIR
              set -x SANDBOXED_PATH "$SANDBOXED_PATH$SEP$(realpath $DIR)"
              if test -z "$SEP"
                set SEP ":"
              end
            end
          end

          set SEP ""
          set SANDBOXED_MANPATH ""
          for DIR in $(string split : $MANPATH)
            if test -d $DIR
              set -x SANDBOXED_MANPATH "$SANDBOXED_MANPATH$SEP$(realpath $DIR)"
              if test -z "$SEP"
                set SEP ":"
              end
            end
          end

          set SEP ""
          set SANDBOXED_TERMINFO_DIRS ""
          for DIR in $(string split : $TERMINFO_DIRS)
            if test -d $DIR
              set -x SANDBOXED_TERMINFO_DIRS "$SANDBOXED_TERMINFO_DIRS$SEP$(realpath $DIR)"
              if test -z "$SEP"
                set SEP ":"
              end
            end
          end

          set SEP ""
          set SANDBOXED_XDG_CONFIG_DIRS ""
          for DIR in $(string split : $XDG_CONFIG_DIRS)
            if test -d $DIR
              set -x SANDBOXED_XDG_CONFIG_DIRS "$SANDBOXED_XDG_CONFIG_DIRS$SEP$(realpath $DIR)"
              if test -z "$SEP"
                set SEP ":"
              end
            end
          end

          set SEP ""
          set SANDBOXED_XDG_DATA_DIRS ""
          for DIR in $(string split : $XDG_DATA_DIRS)
            if test -d $DIR
              set -x SANDBOXED_XDG_DATA_DIRS "$SANDBOXED_XDG_DATA_DIRS$SEP$(realpath $DIR)"
              if test -z "$SEP"
                set SEP ":"
              end
            end
          end

          eval env -S \
            (test -z "$SANDBOXED_PATH" && echo -n "-u PATH") \
            (test -z "$SANDBOXED_MANPATH" && echo -n "-u MANPATH") \
            (test -z "$SANDBOXED_TERMINFO_DIRS" && echo -n "-u TERMINFO_DIRS") \
            (test -z "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "-u XDG_CONFIG_DIRS") \
            (test -z "$SANDBOXED_XDG_DATA_DIRS" && echo -n "-u XDG_DATA_DIRS") \
            (test -n "$SANDBOXED_PATH" && echo -n "PATH=\"$SANDBOXED_PATH\"") \
            (test -n "$SANDBOXED_MANPATH" && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
            (test -n "$SANDBOXED_TERMINFO_DIRS" && echo -n "TERMINFO_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
            (test -n "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
            (test -n "$SANDBOXED_XDG_DATA_DIRS" && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
            $NONO_EXEC $argv

          set -e SANDBOXED_PATH
          set -e SANDBOXED_MANPATH
          set -e SANDBOXED_TERMINFO_DIRS
          set -e SANDBOXED_XDG_CONFIG_DIRS
          set -e SANDBOXED_XDG_DATA_DIRS
        '';
        claude = ''
          set CLAUDE_CODE_EXEC $(realpath $(which claude))

          if string match "*/scripts/claude" $CLAUDE_CODE_EXEC &> /dev/null; or test -n "$CLAUDECODE"; or test -n "$NONO_CAP_FILE"
            $CLAUDE_CODE_EXEC $argv
          else
            # Note that all of the allow/allow-file/read/read-file lines
            # (except for `--allow .`) can be removed when nono v0.6.0
            # hits nixpkgs-unstable
            #
            nono run \
              --profile claude-code \
              --allow . \
              (test -d $HOME/.bash_sessions && echo -n "--allow $HOME/.bash_sessions") \
              (test -d $XDG_CACHE_HOME/fish && echo -n "--allow $XDG_CACHE_HOME/fish") \
              (test -d $XDG_CACHE_HOME/go-build && echo -n "--allow $XDG_CACHE_HOME/go-build") \
              (test -d $XDG_CACHE_HOME/pip && echo -n "--allow $XDG_CACHE_HOME/pip") \
              (test -d $XDG_CACHE_HOME/pnpm && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
              (test -d $XDG_CACHE_HOME/starship && echo -n "--allow $XDG_CACHE_HOME/starship") \
              (test -d $XDG_CACHE_HOME/uv && echo -n "--allow $XDG_CACHE_HOME/uv") \
              (test -d $XDG_CONFIG_HOME/go && echo -n "--allow $XDG_CONFIG_HOME/go") \
              (test -d $XDG_CONFIG_HOME/zsh && echo -n "--allow $XDG_CONFIG_HOME/zsh") \
              (test -d $XDG_DATA_HOME/fish && echo -n "--allow $XDG_DATA_HOME/fish") \
              (test -d $XDG_DATA_HOME/pnpm && echo -n "--allow $XDG_DATA_HOME/pnpm") \
              (test -d $XDG_STATE_HOME/pnpm && echo -n "--allow $XDG_STATE_HOME/pnpm") \
              (test -d /tmp && echo -n "--allow /tmp") \
              (test -d /var/folders && echo -n "--allow /var/folders") \
              (test -e /dev/null && echo -n "--allow-file /dev/null") \
              (test -d $HOME/.ssh && echo -n "--read $HOME/.ssh") \
              (test -d $HOME/Library/"Application Support"/Chromium && echo -n "--read $HOME/Library/Application\\ Support/Chromium") \
              (test -d $HOME/Library/"Application Support"/Google/Chrome && echo -n "--read $HOME/Library/Application\\ Support/Google/Chrome") \
              (test -d $XDG_CACHE_HOME/bat && echo -n "--read $XDG_CACHE_HOME/bat") \
              (test -d $XDG_CONFIG_HOME/chromium && echo -n "--read $XDG_CONFIG_HOME/chromium") \
              (test -d $XDG_CONFIG_HOME/fish && echo -n "--read $XDG_CONFIG_HOME/fish") \
              (test -d $XDG_CONFIG_HOME/google-chrome && echo -n "--read $XDG_CONFIG_HOME/google-chrome") \
              (test -d $XDG_CONFIG_HOME/starship && echo -n "--read $XDG_CONFIG_HOME/starship") \
              (test -d /etc/skel && echo -n "--read /etc/skel") \
              (test -d /nix && echo -n "--read /nix") \
              (test -e $HOME/.bash_aliases && echo -n "--read-file $HOME/.bash_aliases") \
              (test -e /etc/bashrc && echo -n "--read-file /etc/bashrc") \
              -- $CLAUDE_CODE_EXEC --dangerously-skip-permissions $argv
          end
        '';
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        # Convenience function for launching graphical apps from the terminal
        #
        xcv = "nohup $argv 2>/dev/null";
      };
  };
}
