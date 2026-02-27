{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    dconf2nix

    #### Fonts ####
    #nerd-fonts.jetbrains-mono # TODO: Uncomment once the Android Terminal supports custom fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji

    #### Additional wallpapers ####
    #
    # NOTE: These need to be explicitly included in home.packages in
    # order to show up in the GNOME Control Center
    #
    elementary-wallpapers
    pop-wallpapers
  ];

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      emoji = ["Noto Emoji"];
      monospace = [
        "Noto Sans Mono" # TODO: Switch to "JetBrainsMono Nerd Font Mono" once the Android Terminal supports custom fonts
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
  xdg.desktopEntries."vim" = {
    noDisplay = true;
    settings = {
      Hidden = true;
    };
  };
}
