{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.tmux = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.tmux
      else null;

    baseIndex = 1;
    clock24 = true;
    mouse = true;
    resizeAmount = 1;
    shell = "${config.programs.fish.package}/bin/fish";
    shortcut = "a";

    # Use tmuxPackages.sensible to apply the following defaults:
    #
    #   set -s escape-time 0
    #   set -g history-limit 50000
    #   set -g display-time 4000
    #   set -g status-interval 5
    #   set -g default-command "reattach-to-user-namespace -l $SHELL"
    #   set -g default-terminal "screen-256color"
    #   set -g status-keys emacs
    #   set -g focus-events on
    #   setw -g aggressive-resize on
    #
    # NOTE: We have to RESET these same values explicitly as well, since
    # otherwise the home-manager defaults will override them
    #
    sensibleOnTop = true;

    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";
    focusEvents = true;
    aggressiveResize = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.gruvbox;
        extraConfig = ''
          set -g @tmux-gruvbox "light"
          set -g @tmux-gruvbox-right-status-y "%H:%M:%S"
          set -g @tmux-gruvbox-right-status-z "#h #{tmux_mode_indicator}"
        '';
      }
      {
        plugin = tmuxPlugins.mode-indicator;
        extraConfig = ''
          set -g @mode_indicator_prefix_mode_style 'bg=blue,fg=#fbf1c7'
          set -g @mode_indicator_copy_mode_style 'bg=yellow,fg=#fbf1c7'
          set -g @mode_indicator_sync_mode_style 'bg=red,fg=#fbf1c7'
          set -g @mode_indicator_empty_mode_style 'bg=cyan,fg=#fbf1c7'
        '';
      }
      {
        plugin = tmuxPlugins.better-mouse-mode;
        extraConfig = ''
          set -g @scroll-without-changing-pane "on"
          set -g @scroll-speed-num-lines-per-scroll 1
          set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
        '';
      }
      {
        plugin = tmuxPlugins.fuzzback;
        extraConfig = ''
          set -g @fuzzback-popup 1
          set -g @fuzzback-popup-size '100%'
        '';
      }
    ];

    extraConfig =
      ''
        # Tweak tmuxPlugins.gruvbox colors
        #
        run-shell ${config.home.homeDirectory}/${config.xdg.configFile."tmux/scripts/tweak-gruvbox.sh".target}

        # Hook session creation for Zellij-like naming
        #
        set-hook -ag after-new-session "run-shell ${config.home.homeDirectory}/${config.xdg.configFile."tmux/scripts/zellij-session-name.sh".target}"

        # Better pane/tab names
        #
        setw -g automatic-rename-format "#{?pane_in_mode,[tmux],#{?pane_dead,[dead],#{?#{m/r:(bash|zsh|sh|fish),#{pane_current_command}},#{?#{==:#{=16:pane_current_path},#{pane_current_path}},#{pane_current_path},../#{b:pane_current_path}},#{pane_current_command}  #{?#{==:#{=16:pane_current_path},#{pane_current_path}},#{pane_current_path},../#{b:pane_current_path}}}}}"


        # Refresh status bar once per second, since the clock displays
        # seconds
        #
        set -g status-interval 1
      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''

        # tmuxPackages.sensible sets default-command using the SHELL
        # environment variable, but this happens when the command is
        # defined, and home-manager doesn't provide the capability to
        # reset this variable before loading plugins. The only option to
        # fix this behavior is thus to override default-command late in
        # the configuration.
        #
        set -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${config.programs.tmux.shell}"
      '';
  };

  # Convenience scripts
  #
  xdg.configFile = {
    "tmux/scripts/tweak-gruvbox.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        function tweak_attribute {
          TYPE="$1"
          OPTION="$2"
          ATTRIBUTE_FROM="$3"
          ATTRIBUTE_TO="$4"

          if [[ "$TYPE" == "session" ]]; then
            SET="set"
            SHOW="show"
          elif [[ "$TYPE" == "window" ]]; then
            SET="setw"
            SHOW="showw"
          else
            exit
          fi

          tmux "$SET" -g "$OPTION" "$(tmux "$SHOW" -g "$OPTION" | sed "s/^[^\"]\{1,\} \"\{0,1\}//;s/\"\{0,1\}$//;s/$ATTRIBUTE_FROM/$ATTRIBUTE_TO/g")"
        }

        COLOR_SCHEME="$(tmux show -g @tmux-gruvbox | sed 's/^[^"]\{1,\} "\{0,1\}//;s/"\{0,1\}$//')"

        if [[ "$COLOR_SCHEME" == "light" ]]; then
          tweak_attribute session message-command-style         "fg=#ebdbb2" "fg=#fbf1c7"
          tweak_attribute session status-left                   "fg=#665c54" "fg=#fbf1c7"
          tweak_attribute session status-left                   "bg=#bdae93" "bg=#665c54"
          tweak_attribute session status-left                   "fg=#bdae93" "fg=#665c54"
          tweak_attribute session status-right                  "fg=#ebdbb2" "fg=#fbf1c7"
          tweak_attribute window  menu-selected-style           "fg=black"   "fg=#fbf1c7"
          tweak_attribute window  copy-mode-match-style         "fg=black"   "fg=#fbf1c7"
          tweak_attribute window  copy-mode-current-match-style "fg=black"   "fg=#fbf1c7"
          tweak_attribute window  copy-mode-mark-style          "fg=black"   "fg=#fbf1c7"
          tweak_attribute window  mode-style                    "fg=black"   "fg=#fbf1c7"
          tweak_attribute window  window-status-current-format  "fg=#d5c4a1" "fg=#fbf1c7"
          tweak_attribute window  window-status-current-format  ",bold"      ",nobold"
          tweak_attribute window  window-status-current-style   "fg=#ebdbb2" "fg=#fbf1c7"
          tweak_attribute window  window-status-style           "fg=#ebdbb2" "fg=#fbf1c7"
        fi
      '';
    };
    "tmux/scripts/zellij-session-name.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Adjective and noun lists, stolen from Zellij's
        # zellij-utils/src/sessions.rs on 2026-06-18
        #
        ADJECTIVES=(
          "adamant"
          "adept"
          "adventurous"
          "arcadian"
          "auspicious"
          "awesome"
          "blossoming"
          "brave"
          "charming"
          "chatty"
          "circular"
          "considerate"
          "cubic"
          "curious"
          "delighted"
          "didactic"
          "diligent"
          "effulgent"
          "erudite"
          "excellent"
          "exquisite"
          "fabulous"
          "fascinating"
          "friendly"
          "glowing"
          "gracious"
          "gregarious"
          "hopeful"
          "implacable"
          "inventive"
          "joyous"
          "judicious"
          "jumping"
          "kind"
          "likable"
          "loyal"
          "lucky"
          "marvellous"
          "mellifluous"
          "nautical"
          "oblong"
          "outstanding"
          "polished"
          "polite"
          "profound"
          "quadratic"
          "quiet"
          "rectangular"
          "remarkable"
          "rusty"
          "sensible"
          "sincere"
          "sparkling"
          "splendid"
          "stellar"
          "tenacious"
          "tremendous"
          "triangular"
          "undulating"
          "unflappable"
          "unique"
          "verdant"
          "vitreous"
          "wise"
          "zippy"
        )

        NOUNS=(
          "aardvark"
          "accordion"
          "apple"
          "apricot"
          "bee"
          "brachiosaur"
          "cactus"
          "capsicum"
          "clarinet"
          "cowbell"
          "crab"
          "cuckoo"
          "cymbal"
          "diplodocus"
          "donkey"
          "drum"
          "duck"
          "echidna"
          "elephant"
          "foxglove"
          "galaxy"
          "glockenspiel"
          "goose"
          "hill"
          "horse"
          "iguanadon"
          "jellyfish"
          "kangaroo"
          "lake"
          "lemon"
          "lemur"
          "magpie"
          "megalodon"
          "mountain"
          "mouse"
          "muskrat"
          "newt"
          "oboe"
          "ocelot"
          "orange"
          "panda"
          "peach"
          "pepper"
          "petunia"
          "pheasant"
          "piano"
          "pigeon"
          "platypus"
          "quasar"
          "rhinoceros"
          "river"
          "rustacean"
          "salamander"
          "sitar"
          "stegosaurus"
          "tambourine"
          "tiger"
          "tomato"
          "triceratops"
          "ukulele"
          "viola"
          "weasel"
          "xylophone"
          "yak"
          "zebra"
        )

        tmux rename-session "$(printf "%s\n" "''${ADJECTIVES[@]}" | shuf -n1)-$(printf "%s\n" "''${NOUNS[@]}" | shuf -n1)"
      '';
    };
  };

  # Auto-start tmux
  #
  # NOTE: The naming is funny because we want to be sure that this
  # always runs LAST
  #
  xdg.configFile."bash/rc.d/zz_tmux.sh" = {
    enable = config.programs.bash.enable && ("${config.home.username}" == "droid");
    text = ''
      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ ! -f "$HOME/notmux" ]] && [[ ! -f "$HOME/notmux.txt" ]] && [[ ! -f /mnt/shared/Documents/notmux ]] && [[ ! -f /mnt/shared/Documents/notmux.txt ]]; then
        TMUX_SESSION="$(tmux list-sessions -F '#{session_name}' -f '#{?session_attached,0,1}' | head -n1)"
        if [[ -n "$TMUX_SESSION" ]]; then
          tmux attach-session -t "$TMUX_SESSION" && exit
        else
          tmux new-session && exit
        fi
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/zz_tmux.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.isDarwin;
    text = ''
      if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ ! -f "$HOME/notmux" ]] && [[ ! -f "$HOME/notmux.txt" ]] && [[ ! -f /mnt/shared/Documents/notmux ]] && [[ ! -f /mnt/shared/Documents/notmux.txt ]]; then
        TMUX_SESSION="$(tmux list-sessions -F '#{session_name}' -f '#{?session_attached,0,1}' | head -n1)"
        if [[ -n "$TMUX_SESSION" ]]; then
          tmux attach-session -t "$TMUX_SESSION" && exit
        else
          tmux new-session && exit
        fi
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zz_tmux.fish" = {
    enable = config.programs.fish.enable && false;
    text = ''
      if status --is-interactive; and test -z "$TMUX"; and test ! -f $HOME/notmux; and test ! -f $HOME/notmux.txt; and test ! -f /mnt/shared/Documents/notmux; and test ! -f /mnt/shared/Documents/notmux.txt
        set TMUX_SESSION $(tmux list-sessions -F '#{session_name}' -f '#{?session_attached,0,1}' | head -n1)
        if test -n "$TMUX_SESSION"
          tmux attach-session -t "$TMUX_SESSION" && exit
        else
          tmux new-session && exit
        end
      end
    '';
  };
}
