{
  pkgs,
  config,
  llm-agents,
  ...
}: let
  localPkgs = {
    claude = pkgs.callPackage ../pkgs/claude.nix {inherit llm-agents;};
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    zellij-launch-editor = pkgs.callPackage ../pkgs/zellij-launch-editor.nix {};
    zellij-launch-ide = pkgs.callPackage ../pkgs/zellij-launch-ide.nix {};
  };
in {
  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "${pkgs.fish}/bin/fish";
      copy_command = "${localPkgs.pbcopy}/bin/pbcopy";

      # The default Zellij Gruvbox dark theme uses the wrong base
      # background color (60 56 54 -> 40 40 40)
      #
      #   https://github.com/zellij-org/zellij/blob/main/zellij-utils/assets/themes/gruvbox-dark.kdl
      #
      # FIXME: Why does this only work when embedded in the config file,
      # and not when set in programs.zellij.themes?
      #
      theme = "gruvbox-dark-mod";
      themes = {
        gruvbox-dark-mod = {
          text_unselected = {
            base = [251 241 199];
            background = [40 40 40];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          text_selected = {
            base = [251 241 199];
            background = [80 73 69];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          ribbon_selected = {
            base = [40 40 40];
            background = [152 151 26];
            emphasis_0 = [204 36 29];
            emphasis_1 = [214 93 14];
            emphasis_2 = [177 98 134];
            emphasis_3 = [69 133 136];
          };
          ribbon_unselected = {
            base = [40 40 40];
            background = [235 219 178];
            emphasis_0 = [204 36 29];
            emphasis_1 = [251 241 199];
            emphasis_2 = [69 133 136];
            emphasis_3 = [177 98 134];
          };
          table_title = {
            base = [152 151 26];
            background = [0];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          table_cell_selected = {
            base = [251 241 199];
            background = [80 73 69];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          table_cell_unselected = {
            base = [251 241 199];
            background = [40 40 40];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          list_selected = {
            base = [251 241 199];
            background = [80 73 69];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          list_unselected = {
            base = [251 241 199];
            background = [40 40 40];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [152 151 26];
            emphasis_3 = [177 98 134];
          };
          frame_selected = {
            base = [152 151 26];
            background = [0];
            emphasis_0 = [214 93 14];
            emphasis_1 = [104 157 106];
            emphasis_2 = [177 98 134];
            emphasis_3 = [0];
          };
          frame_highlight = {
            base = [214 93 14];
            background = [0];
            emphasis_0 = [177 98 134];
            emphasis_1 = [214 93 14];
            emphasis_2 = [214 93 14];
            emphasis_3 = [214 93 14];
          };
          exit_code_success = {
            base = [152 151 26];
            background = [0];
            emphasis_0 = [104 157 106];
            emphasis_1 = [40 40 40];
            emphasis_2 = [177 98 134];
            emphasis_3 = [69 133 136];
          };
          exit_code_error = {
            base = [204 36 29];
            background = [0];
            emphasis_0 = [215 153 33];
            emphasis_1 = [0];
            emphasis_2 = [0];
            emphasis_3 = [0];
          };
          multiplayer_user_colors = {
            player_1 = [177 98 134];
            player_2 = [69 133 136];
            player_3 = [0];
            player_4 = [215 153 33];
            player_5 = [104 157 106];
            player_6 = [0];
            player_7 = [204 36 29];
            player_8 = [0];
            player_9 = [0];
            player_10 = [0];
          };
        };
      };
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
                    "pane stacked=true" = {
                      _children = [
                        {
                          "pane name=\"Terminal\" focus=true expanded=true" = {};
                        }
                        {
                          "pane name=\"Search\"" = {
                            command = "${pkgs.serpl}/bin/serpl";
                            start_suspended = false;
                          };
                        }
                      ];
                    };
                  }
                  {
                    "pane stacked=true" = {
                      _children = [
                        {
                          "pane name=\"Helix\" expanded=true" = {
                            command = "${config.programs.helix.package}/bin/hx";
                            start_suspended = false;
                          };
                        }
                        {
                          "pane name=\"Claude\"" = {
                            command = "${localPkgs.claude}/bin/claude";
                            start_suspended = true;
                          };
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

  # Custom commands for the Zellij + Helix + Claude IDE
  #
  xdg.configFile."bash/rc.d/zellij.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
        alias ide=${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
        alias edit=${localPkgs.zellij-launch-editor}/bin/zellij-launch-editor
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/zellij.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
        alias ide=${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
        alias edit=${localPkgs.zellij-launch-editor}/bin/zellij-launch-editor
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zellij.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -n "$ZELLIJ_SESSION_NAME"
        alias ide ${localPkgs.zellij-launch-ide}/bin/zellij-launch-ide
        alias edit ${localPkgs.zellij-launch-editor}/bin/zellij-launch-editor
      end
    '';
  };
}
