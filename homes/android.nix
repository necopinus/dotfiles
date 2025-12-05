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
    ../programs/labwc.nix
  ];

  programs.home-manager.enable = true; # Make sure that home-manager binary is in the PATH
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
      # Stuff
    };

    dataFile = {
      # Hide some desktop applications
      #
      "applications/pavucontrol.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      "applications/zutty.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
    };
  };

  # No-frills theme configuration
  #
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
    qt.platformTheme.name = "adwaita"; # or maybe `lxqt`?
    style.name = "adwaita-dark";
  };

  # Additional Android-specific environment variables
  #
  home.sessionVariables = {
    ZED_ALLOW_EMULATED_GPU = 1;
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
