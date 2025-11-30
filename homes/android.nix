{
  config,
  pkgs,
  ...
}: let
  localPkgs = {
    pbcopy = pkgs.callPackage ../pkgs/pbcopy.nix {};
    pbpaste = pkgs.callPackage ../pkgs/pbpaste.nix {};
    start-desktop = pkgs.callPackage ../pkgs/start-desktop.nix {};
  };
in {
  # Make sure that the home-manager binary is available in the PATH
  #
  programs.home-manager.enable = true;

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig = {
    enable = true;

    # TODO: Double-check these names and add intermediate CJK fonts
    #
    defaultFonts = {
      emoji = ["Noto Emoji"];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Emoji"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Emoji"
      ];
      serif = [
        "Noto Serif"
        "Noto Emoji"
      ];
    };
  };

  programs.obsidian.enable = true;

  home.packages = with pkgs; [
    calibre

    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji

    #### Local packages (see above) ####
    localPkgs.pbcopy
    localPkgs.pbpaste
    localPkgs.start-desktop
  ];

  xdg = {
    enabled = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/data/desktop";
      documents = "${config.home.homeDirectory}/data";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/data/music";
      pictures = "${config.home.homeDirectory}/data/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/data/templates";
      videos = "${config.home.homeDirectory}/data/videos";
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
        "x-scheme-handler/http" = ["xfce4-web-browser.desktop"];
        "x-scheme-handler/https" = ["xfce4-web-browser.desktop"];
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
  };

  home.file = {
    ".gnupg/gpg-agent.conf".source = ../artifacts/gnupg/gpg-agent.conf;

    # Disable default application startups
    #
    "config/autostart/light-locker.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "config/autostart/xiccd.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

    # Hide some desktop applications
    #
    "local/share/applications/fish.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/org.gnome.Vte.App.Gtk3.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/org.gnome.Vte.App.Gtk4.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/xfce4-terminal.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    "local/share/applications/zutty.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

    # Xfce files
    #
    "config/xfce4/helpers.rc" = ../artifacts/config/xfce4/helpers.rc;
    "local/share/xfce4/helpers/custom-TerminalEmulator.desktop" = ../artifacts/local/share/xfce4/helpers/custom-TerminalEmulator.desktop;
    "local/share/xfce4/helpers/custom-WebBrowser.desktop" = ../artifacts/local/share/xfce4/helpers/custom-WebBrowser.desktop;
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

        "backdrop/screeon0/monitor0/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitor0/color-style" = 0;
        "backdrop/screeon0/monitor0/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];

        "backdrop/screeon0/monitor1/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitor1/color-style" = 0;
        "backdrop/screeon0/monitor1/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];

        "backdrop/screeon0/monitorVNC-0/workspace0/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitorVNC-0/workspace0/color-style" = 0;
        "backdrop/screeon0/monitorVNC-0/workspace0/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];

        "backdrop/screeon0/monitorVNC-0/workspace1/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitorVNC-0/workspace1/color-style" = 0;
        "backdrop/screeon0/monitorVNC-0/workspace1/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];

        "backdrop/screeon0/monitorVNC-0/workspace2/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitorVNC-0/workspace2/color-style" = 0;
        "backdrop/screeon0/monitorVNC-0/workspace2/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];

        "backdrop/screeon0/monitorVNC-0/workspace3/last-image" = "/usr/share/backgrounds/xfce/xfce-leaves.svg";
        "backdrop/screeon0/monitorVNC-0/workspace3/color-style" = 0;
        "backdrop/screeon0/monitorVNC-0/workspace3/rgba1" = [0.23921568627450981 0.2196078431372549 0.27450980392156865 1];
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
        "panels/panel-1/length" = 100;
        "panels/panel-1/position-locked" = true;
        "panels/panel-1/icon-size" = 16;
        "panels/panel-1/size" = 26;
        "panels/panel-1/plugin-ids" = [1 2 5 6 8 10 11 12 13];
        "plugins/plugin-1" = "applicationsmenu";
        "plugins/plugin-2" = "tasklist";
        "plugins/plugin-2/grouping" = 1;
        "plugins/plugin-2/flat-buttons" = true;
        "plugins/plugin-5" = "separator";
        "plugins/plugin-5/style" = 0;
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
        "plugins/plugin-11/style" = 0;
        "plugins/plugin-12" = "clock";
        "plugins/plugin-12/digital-layout" = 2;
        "plugins/plugin-12/digital-date-font" = "JetBrainsMono Nerd Font 10";
        "plugins/plugin-12/digital-date-format" = "%Y-%m-%d @ %H:%M";
        "plugins/plugin-12/tooltip-format" = "%A %B %d, %Y";
        "plugins/plugin-13" = "separator";
        "plugins/plugin-13/style" = 0;
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

  # Make sure that systemd units pick up as many session variables as
  # possible
  #
  systemd.user.sessionVariables = config.home.sessionVariables;
}
