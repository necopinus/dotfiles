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
  imports = [
    ../programs/lxqt.nix
  ];

  programs.home-manager.enable = true; # Make sure that home-manager binary is in the PATH
  programs.obsidian.enable = true;

  home.packages = with pkgs; [
    calibre
    util-linux

    #### Look and feel ####
    adwaita-icon-theme-legacy # MoreWaita dependency; do NOT include adwaita-icon-theme here to prevent duplication errors!
    morewaita-icon-theme

    lomiri.lomiri-wallpapers
    pantheon.elementary-wallpapers
    pop-wallpapers

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

  # XDG configuration
  #
  xdg = {
    enable = true;

    systemDirs = {
      config = [
        "${config.home.homeDirectory}/.nix-profile/etc/xdg"
        "/nix/var/nix/profiles/default/etc/xdg"
        "/etc/xdg"
      ];
      data = [
        "${config.home.homeDirectory}/.nix-profile/share"
        "/nix/var/nix/profiles/default/share"
        "/usr/local/share"
        "/usr/share"
      ];
    };

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
      # Disable some autostart entries; we don't use xdg.autostart
      # because that only allows us to ADD entries, and masking in this
      # fashion is more economical
      #
      "autostart.lxqt-xscreensaver-autostart.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

      # QT KvLibadwaita is the closest thing to (current) Adwaita for Qt
      # apps that I've managed to get working
      #
      "Kvantum/Colors".source = ../third-party/kvantum-adwaita/Colors;
      "Kvantum/KvLibadwaita".source = ../third-party/kvantum-adwaita/KvLibadwaita;
    };

    dataFile = {
      # Hide some desktop applications
      #
      "applications/bottom.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/calibre-ebook-edit.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/calibre-lrfviewer.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/Helix.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-config-brightness.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-config-monitor.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-hibernate.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-lockscreen.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-reboot.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-shutdown.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/lxqt-suspend.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

      # Unified backgrounds folder
      #
      "backgrounds/A Large Body of Water Surrounded By Mountains.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/A Large Body of Water Surrounded By Mountains.jpg";
      "backgrounds/ahmadreza-sajadi-10140-edit.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/ahmadreza-sajadi-10140-edit.jpg";
      "backgrounds/A Trail of Footprints In The Sand.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/A Trail of Footprints In The Sand.jpg";
      "backgrounds/Ashim DSilva.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Ashim DSilva.jpg";
      "backgrounds/benjamin-voros-250200.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/benjamin-voros-250200.jpg";
      "backgrounds/Canazei Granite Ridges.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Canazei Granite Ridges.jpg";
      "backgrounds/galen-crout-175291.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/galen-crout-175291.jpg";
      "backgrounds/jad-limcaco-183877.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/jad-limcaco-183877.jpg";
      "backgrounds/jared-evans-119758.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/jared-evans-119758.jpg";
      "backgrounds/jasper-van-der-meij-97274-edit.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/jasper-van-der-meij-97274-edit.jpg";
      "backgrounds/kait-herzog-8242.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/kait-herzog-8242.jpg";
      "backgrounds/Kleiber_by_Lukas_Baubkus.jpg".source = "${pkgs.lomiri.lomiri-wallpapers}/share/wallpapers/Kleiber_by_Lukas_Baubkus.jpg";
      "backgrounds/Morskie Oko.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Morskie Oko.jpg";
      "backgrounds/Mr. Lee.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Mr. Lee.jpg";
      "backgrounds/Nattu Adnan.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Nattu Adnan.jpg";
      "backgrounds/odin.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/odin.jpg";
      "backgrounds/odin-dark.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/odin-dark.jpg";
      "backgrounds/Photo of Valley.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Photo of Valley.jpg";
      "backgrounds/sean-afnan-244576.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/sean-afnan-244576.jpg";
      "backgrounds/Snow-Capped Mountain.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Snow-Capped Mountain.jpg";
      "backgrounds/spacex-81773.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/spacex-81773.jpg";
      "backgrounds/Sunset by the Pier.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Sunset by the Pier.jpg";
      "backgrounds/tim-mccartney-39907.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/tim-mccartney-39907.jpg";
      "backgrounds/Tj Holowaychuk.jpg".source = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Tj Holowaychuk.jpg";
      "backgrounds/tony-webster-97532.jpg".source = "${pkgs.pop-wallpapers}/share/backgrounds/pop/tony-webster-97532.jpg";
    };
  };

  # No-frills theme configuration
  #
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme.name = "Adwaita";
    cursorTheme.name = "Adwaita";
    iconTheme.name = "MoreWaita";
    font = {
      name = "Noto Sans";
      size = 10;
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
  };

  # The Android VM runs Debian, not NixOS
  #
  targets.genericLinux.enable = true;

  # https://github.com/nix-community/home-manager/issues/2033
  #
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };

  # Make sure that systemd units pick up as many environment variables
  # as possible
  #
  systemd.user.sessionVariables = config.home.sessionVariables;
}
