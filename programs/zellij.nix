{
  pkgs,
  config,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {inherit llm-agents;};
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    zellij-launch-helix = pkgs.callPackage ../pkgs/zellij-launch-helix.nix {};
    zellij-launch-ide = pkgs.callPackage ../pkgs/zellij-launch-ide.nix {};
    zellij-post-command-discovery-hook = pkgs.callPackage ../pkgs/zellij-post-command-discovery-hook.nix {};
  };
in {
  programs.zellij = {
    enable = true;

    settings = {
      theme = "ansi";
      default_shell = "${pkgs.fish}/bin/fish";

      # Setting `post_command_discovery_hook` makes
      # `zellij-launch-helix` more robust, but also INSANELY SLOW
      #
      #post_command_discovery_hook = "${localPkgs.zellij-post-command-discovery-hook}/bin/zellij-post-command-discovery-hook";

      copy_command = "${localPkgs.pbcopy}/bin/pbcopy";
    };
    extraConfig = ''
      keybinds {
        shared_except "locked" {
          unbind "Alt f"
          bind "Alt Shift f" { ToggleFloatingPanes; }

          bind "Alt Shift Left" { MoveFocusOrTab "Left"; }
          bind "Alt Shift Right" { MoveFocusOrTab "Right"; }
          bind "Alt Shift Down" { MoveFocus "Down"; }
          bind "Alt Shift Up" { MoveFocus "Up"; }
        }
      }
    '';

    # Custom "IDE" layout
    #
    layouts = {
      ide = {
        layout = {
          _children = [
            {
              "pane size=1 borderless=true" = {
                "plugin location=\"zellij:tab-bar\"" = {};
              };
            }
            {
              "pane split_direction=\"vertical\"" = {
                _children = [
                  {
                    "pane name=\"Files\" size=\"20%\"" = {
                      "plugin location=\"zellij:strider\"" = {};
                    };
                  }
                  {
                    "pane size=\"80%\" stacked=true" = {
                      _children = [
                        {
                          "pane name=\"Claude\"" = {
                            command = "${localPkgs.claude}/bin/claude";
                            start_suspended = true;
                          };
                        }
                        {
                          "pane name=\"Helix\" focus=true expanded=true" = {
                            command = "${config.programs.helix.package}/bin/hx";
                            start_suspended = false;
                          };
                        }
                        {
                          "pane name=\"Search\"" = {
                            command = "${pkgs.serpl}/bin/serpl";
                            start_suspended = false;
                          };
                        }
                        {
                          "pane name=\"Terminal\"" = {};
                        }
                      ];
                    };
                  }
                ];
              };
            }
            {
              "pane size=1 borderless=true" = {
                "plugin location=\"zellij:status-bar\"" = {};
              };
            }
          ];
        };
      };
    };

    # Do not enable the fish shell integration, as we use Zellij to
    # start fish in the first place
    #
    # FIXME: Why do I explicitly have to set the bash and zsh
    # integrations here, but not for other programs?
    #
    enableBashIntegration = true;
    enableFishIntegration = false;
    enableZshIntegration = true;

    # We live in Zellij now, the parent shell is but a memory
    #
    exitShellOnExit = true;
  };

  # Set the zellij-launch-helix wrapper as our EDITOR. We do this when
  # we're NOT in Zellij, since we want Zellij to pick up this value. But
  # we DON'T want to set this WITHIN Zellij, so that fish will source
  # the home-manager variables and properly set EDITOR to point to
  # Helix.
  #
  # Got that?
  #
  xdg.configFile."bash/env.d/zellij.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
        export EDITOR=${localPkgs.zellij-launch-helix}/bin/zellij-launch-helix
      else
        export EDITOR="$VISUAL"
      fi
    '';
  };
  xdg.configFile."zsh/env.d/zellij.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -z "$ZELLIJ_SESSION_NAME" ]]; then
        export EDITOR=${localPkgs.zellij-launch-helix}/bin/zellij-launch-helix
      else
        export EDITOR="$VISUAL"
      fi
    '';
  };
  xdg.configFile."fish/env.d/zellij.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -z "$ZELLIJ_SESSION_NAME"
        set -x EDITOR ${localPkgs.zellij-launch-helix}/bin/zellij-launch-helix
      else
        set -x EDITOR $VISUAL
      end
    '';
  };

  # Custom command to launch our Zellij + Helix + Claude IDE
  #
  xdg.configFile."bash/rc.d/zellij.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
        alias ide=${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/zellij.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
        alias ide=${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zellij.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -n "$ZELLIJ_SESSION_NAME"
        alias ide ${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
      end
    '';
  };
}
