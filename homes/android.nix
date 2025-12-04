{
  config,
  lib,
  pkgs,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
  };
in {
  # The Android VM runs Debian, not NixOS
  #
  targets.genericLinux.enable = true;

  # Make sure that the home-manager binary is available in the PATH
  #
  programs.home-manager.enable = true;

  # https://github.com/nix-community/home-manager/issues/2033
  #
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      emoji = ["Noto Emoji"];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
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

  programs.obsidian.enable = true;

  home.packages = with pkgs; [
    calibre
    util-linux

    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji

    #### Local packages (see above) ####
    localPkgs.pbcopy
    localPkgs.pbpaste
  ];

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/data/desktop";
      documents = "/mnt/shared/Documents";
      download = "/mnt/shared/Download";
      music = "/mnt/shared/Music";
      pictures = "/mnt/shared/Pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/data/templates";
      videos = "/mnt/shared/Movies";
    };

    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "org.wezfurlong.wezterm.desktop"
        ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/x-extension-htm" = ["brave-browser.desktop"];
        "application/x-extension-html" = ["brave-browser.desktop"];
        "application/x-extension-shtml" = ["brave-browser.desktop"];
        "application/x-extension-xht" = ["brave-browser.desktop"];
        "application/x-extension-xhtml" = ["brave-browser.desktop"];
        "application/xhtml+xml" = ["brave-browser.desktop"];
        "text/html" = ["brave-browser.desktop"];
        "x-scheme-handler/chrome" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];
      };
      associations.added = {
        "application/pdf" = ["brave-browser.desktop"];
        "application/rdf+xml" = ["brave-browser.desktop"];
        "application/rss+xml" = ["brave-browser.desktop"];
        "application/x-extension-htm" = ["brave-browser.desktop"];
        "application/x-extension-html" = ["brave-browser.desktop"];
        "application/x-extension-shtml" = ["brave-browser.desktop"];
        "application/x-extension-xht" = ["brave-browser.desktop"];
        "application/x-extension-xhtml" = ["brave-browser.desktop"];
        "application/xhtml+xml" = ["brave-browser.desktop"];
        "application/xhtml_xml" = ["brave-browser.desktop"];
        "application/xml" = ["brave-browser.desktop"];
        "text/html" = ["brave-browser.desktop"];
        "text/xml" = ["brave-browser.desktop"];
        "x-scheme-handler/chrome" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];
      };
    };

    configFile = {
      # Disable default application startups
      #
      "autostart/light-locker.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "autostart/xiccd.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "autostart/xscreensaver.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

      # Xfce files
      #
      "xfce4/helpers.rc".source = ../artifacts/config/xfce4/helpers.rc;
    };

    dataFile = {
      # Hide some desktop applications
      #
      "applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/zutty.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

      # Xfce files
      #
      "xfce4/helpers/custom-TerminalEmulator.desktop".source = ../artifacts/local/share/xfce4/helpers/custom-TerminalEmulator.desktop;
      "xfce4/helpers/custom-WebBrowser.desktop".source = ../artifacts/local/share/xfce4/helpers/custom-WebBrowser.desktop;
    };
  };

  # Requires Debian "xfce4" metapackage to be installed
  #
  xfconf = {
    enable = true;
    settings = {
      xsettings = {
        "Net/ThemeName" = "Adwaita-dark";
        "Net/IconThemeName" = "Adwaita";
        "Gtk/CursorThemeName" = "Adwaita";
        "Gtk/FontName" = "Noto Sans 10";
        "Gtk/MonospaceFontName" = "JetBrainsMono Nerd Font 10";
      };
      xfce4-desktop = {
        "desktop-icons/style" = 0;

        "backdrop/screen0/monitor0/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screen0/monitor0/color-style" = 0;
        "backdrop/screen0/monitor0/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1.0000000000000000];

        "backdrop/screen0/monitor1/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screen0/monitor1/color-style" = 0;
        "backdrop/screen0/monitor1/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1.0000000000000000];

        "backdrop/screen0/monitorrdp0/workspace0/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screen0/monitorrdp0/workspace0/color-style" = 0;
        "backdrop/screen0/monitorrdp0/workspace0/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1.0000000000000000];
      };
      thunar = {
        "misc-text-beside-icons" = true;
        "misc-full-path-in-tab-title" = true;
      };
      xfwm4 = {
        "general/workspace_count" = 1;
      };
      xfce4-session = {
        "general/PromptOnLogout" = false;
      };
      xfce4-panel = {
        "configver" = 2;
        "panels/dark-mode" = true;
        "panels/panel-1/position" = "p=6;x=949;y=24";
        "panels/panel-1/length" = 100.0000000000000000;
        "panels/panel-1/position-locked" = true;
        "panels/panel-1/icon-size" = {
          type = "uint";
          value = 16;
        };
        "panels/panel-1/size" = {
          type = "uint";
          value = 26;
        };
        "panels/panel-1/plugin-ids" = [1 2 5 6 8 10 11 12 13];
        "plugins/plugin-1" = "applicationsmenu";
        "plugins/plugin-2" = "tasklist";
        "plugins/plugin-2/grouping" = {
          type = "uint";
          value = 1;
        };
        "plugins/plugin-2/flat-buttons" = true;
        "plugins/plugin-5" = "separator";
        "plugins/plugin-5/style" = {
          type = "uint";
          value = 0;
        };
        "plugins/plugin-5/expand" = true;
        "plugins/plugin-6" = "systray";
        "plugins/plugin-6/square-icons" = true;
        "plugins/plugin-6/icon-size" = 16;
        "plugins/plugin-6/single-row" = true;
        "plugins/plugin-6/symbolic-icons" = true;
        "plugins/plugin-8" = "pulseaudio";
        "plugins/plugin-8/enable-keyboard-shortcuts" = true;
        "plugins/plugin-8/show-notifications" = true;
        "plugins/plugin-10" = "notification-plugin";
        "plugins/plugin-11" = "separator";
        "plugins/plugin-11/style" = {
          type = "uint";
          value = 0;
        };
        "plugins/plugin-12" = "clock";
        "plugins/plugin-12/digital-layout" = {
          type = "uint";
          value = 2;
        };
        "plugins/plugin-12/digital-date-font" = "JetBrainsMono Nerd Font 10";
        "plugins/plugin-12/digital-date-format" = "%Y-%m-%d @ %H:%M";
        "plugins/plugin-12/tooltip-format" = "%A %B %d, %Y";
        "plugins/plugin-13" = "separator";
        "plugins/plugin-13/style" = {
          type = "uint";
          value = 0;
        };
      };
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme.name = "Adwaita";
    cursorTheme.name = "Adwaita";
    iconTheme = {
      package = pkgs.adwaita-icon-theme-legacy;
      name = "Adwaita";
    };
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 10;
    };
  };

  qt = {
    enable = true;
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };

  # Additional Android-specific environment variables
  #
  home.sessionVariables = {
    ZED_ALLOW_EMULATED_GPU = 1;
  };

  # Make sure that systemd units pick up as many environment variables
  # as possible
  #
  systemd.user.sessionVariables = config.home.sessionVariables;
}
