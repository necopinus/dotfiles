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
      theme = "ansi";
      default_shell = "${pkgs.fish}/bin/fish";
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
