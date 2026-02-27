{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    dconf2nix

    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji

    #### Additional wallpapers ####
    #
    # NOTE: These need to be explicitly included in home.packages in
    # order to show up in the GNOME Control Center
    #
    pantheon.elementary-wallpapers
    pop-wallpapers
  ];

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      emoji = ["Noto Emoji"];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Sans Mono"
        "Noto Emoji"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK JP"
        "Noto Emoji"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
        "Noto Emoji"
      ];
    };
  };

  # XDG configuration
  #
  xdg.mimeApps.enable = true;

  # No-frills theme configuration
  #
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme.name = "Adwaita";
    cursorTheme.name = "Adwaita";
    iconTheme.name = "Adwaita";
    font = {
      name = "Noto Sans";
      size = 10;
    };
  };

  # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
  #
  dconf.settings = with lib.hm.gvariant; {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/Console" = {
      ignore-scrollback-limit = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/sean-afnan-244576.jpg";
      picture-uri-dark = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/sean-afnan-244576.jpg";
      primary-color = "#000000";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      overlay-scrolling = false;
    };

    "org/gnome/desktop/privacy" = {
      recent-files-max-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-enabled = false;
      picture-options = "zoom";
      picture-uri = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/sean-afnan-244576.jpg";
      primary-color = "#000000";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/nautilus/list-view" = {
      use-tree-view = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "nothing";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
    };
  };

  # Hide extraneous system ViM desktop entry
  #
  # NOTE: We have to do this using xdg.dataFile rather than
  # xdg.desktopEntries because .desktop files in ~/.nix-profile don't
  # mask system-level .desktop files
  #
  xdg.dataFile."applications/vim.desktop".text = ''
    [Desktop Entry]
    Name=Vim
    NoDisplay=true
    Hidden=true
  '';

  # Fix brain dead TERM choice for GNOME Console
  #
  xdg.configFile."bash/env.d/gnome-console.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ "$TERM_PROGRAM" == "kgx" ]] && [[ "$TERM" == "dumb" ]]; then
        export TERM=xterm
      fi
    '';
  };
  xdg.configFile."zsh/env.d/gnome-console.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ "$TERM_PROGRAM" == "kgx" ]] && [[ "$TERM" == "dumb" ]]; then
        export TERM=xterm
      fi
    '';
  };
  xdg.configFile."zsh/env.d/gnome-console.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test "$TERM_PROGRAM" = "kgx"; and test "$TERM" = "dumb"
        set -x TERM xterm
      end
    '';
  };

  # Convenience functions for launching graphical apps from the
  # terminal
  #
  xdg.configFile."bash/rc.d/xcz.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      function xcv {
        ${pkgs.uutils-coreutils-noprefix}/bin/nohup "$@" 2>/dev/null
      }
    '';
  };
  xdg.configFile."zsh/rc.d/xcz.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      function xcv {
        ${pkgs.uutils-coreutils-noprefix}/bin/nohup "$@" 2>/dev/null
      }
    '';
  };
  programs.fish.functions."xcz" = ''
    ${pkgs.uutils-coreutils-noprefix}/bin/nohup $argv 2>/dev/null
  '';
}
