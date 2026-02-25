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
    ../programs/chromium.nix
    ../programs/obsidian.nix
    ../programs/labwc.nix
  ];

  programs.home-manager.enable = true; # Make sure that home-manager binary is in the PATH

  home.packages = with pkgs; [
    libgourou
    quodlibet-full

    #### Look and feel ####
    adwaita-icon-theme-legacy # MoreWaita dependency; do NOT include adwaita-icon-theme here to prevent duplication errors!
    morewaita-icon-theme

    #### Fonts ####
    #nerd-fonts.jetbrains-mono # TODO: Uncomment once the Android Terminal supports custom fonts
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
  xdg = {
    enable = true;
    mimeApps.enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      # The /mnt/shared path can't be changed in the Android VM, so we
      # just follow this pattern everywhere
      #
      desktop = "${config.home.homeDirectory}/data/desktop";
      documents = "/mnt/shared/Documents";
      download = "/mnt/shared/Download";
      music = "/mnt/shared/Music";
      pictures = "/mnt/shared/Pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/data/templates";
      videos = "/mnt/shared/Movies";
    };

    dataFile = {
      # Hide some desktop applications
      #
      "applications/io.github.quodlibet.QuodLibet.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
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

  # VMs are Debian-based, not NixOS
  #
  targets.genericLinux.enable = true;

  # https://github.com/nix-community/home-manager/issues/2033
  #
  news = {
    display = "silent";
    entries = lib.mkForce [];
  };

  # Make sure that systemd units (and regular console sessions) pick up
  # key environment variables
  #
  # XDG_CONFIG_DIRS and XDG_DATA_DIRS are set here rather than in
  # xdg.systemDirs in order to avoid as much path messiness as possible
  #
  systemd.user.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    PATH = "${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games";
    XDG_CACHE_HOME = "${config.xdg.cacheHome}";
    XDG_CONFIG_DIRS = "${config.home.homeDirectory}/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg";
    XDG_CONFIG_HOME = "${config.xdg.configHome}";
    XDG_DATA_DIRS = lib.mkForce "${config.home.homeDirectory}/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share";
    XDG_DATA_HOME = "${config.xdg.dataHome}";
    XDG_STATE_HOME = "${config.xdg.stateHome}";
  };

  home.sessionVariables = {
    XDG_CONFIG_DIRS = "${config.home.homeDirectory}/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg";
    XDG_DATA_DIRS = lib.mkForce "${config.home.homeDirectory}/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share";
  };
}
