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
    mimeApps.enable = true;

    dataFile = {
      # Hide some desktop applications
      #
      #"applications/io.github.quodlibet.QuodLibet.desktop".source = ../artifacts/local/share/applications/hidden.desktop;
      #"applications/vim.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

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
  systemd.user.sessionVariables = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    PATH = "${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games";
    XDG_CACHE_HOME = "${config.xdg.cacheHome}";
    XDG_CONFIG_DIRS = "${config.home.sessionVariables.XDG_CONFIG_DIRS}";
    XDG_CONFIG_HOME = "${config.xdg.configHome}";
    XDG_DATA_DIRS = lib.mkForce "${config.home.sessionVariables.XDG_DATA_DIRS}";
    XDG_DATA_HOME = "${config.xdg.dataHome}";
    XDG_STATE_HOME = "${config.xdg.stateHome}";
  };

  # Cargo-culted from Google's /usr/local/bin/enable_gfxstream on
  # 2025-12-09
  #
  xdg.configFile."bash/env.d/gfxstream.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [[ -f /usr/share/vulkan/icd.d/gfxstream_vk_icd.json ]]; then
        MESA_LOADER_DRIVER_OVERRIDE="zink"
        VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/gfxstream_vk_icd.json"
        MESA_VK_WSI_DEBUG="sw,linear"
        XWAYLAND_NO_GLAMOR=1
        LIBGL_KOPPER_DRI2=1
      fi
    '';
  };
  xdg.configFile."zsh/env.d/gfxstream.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -f /usr/share/vulkan/icd.d/gfxstream_vk_icd.json ]]; then
        MESA_LOADER_DRIVER_OVERRIDE="zink"
        VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/gfxstream_vk_icd.json"
        MESA_VK_WSI_DEBUG="sw,linear"
        XWAYLAND_NO_GLAMOR=1
        LIBGL_KOPPER_DRI2=1
      fi
    '';
  };
  xdg.configFile."fish/env.d/gfxstream.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -f /usr/share/vulkan/icd.d/gfxstream_vk_icd.json
        set -x MESA_LOADER_DRIVER_OVERRIDE "zink"
        set -x VK_ICD_FILENAMES "/usr/share/vulkan/icd.d/gfxstream_vk_icd.json"
        set -x MESA_VK_WSI_DEBUG "sw,linear"
        set -x XWAYLAND_NO_GLAMOR 1
        set -x LIBGL_KOPPER_DRI2 1
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
        nohup "$@" 2>/dev/null
      }
    '';
  };
  xdg.configFile."zsh/rc.d/xcz.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      function xcv {
        nohup "$@" 2>/dev/null
      }
    '';
  };
  programs.fish.functions."xcz" = ''
    nohup $argv 2>/dev/null
  '';

  # The Android VM is surprisingly fragile, so we want to do a
  # shutdown rather than just exiting the last session
  #
  xdg.configFile."bash/rc.d/shutdown.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias shutdown="/usr/bin/sudo /sbin/shutdown -h now"
    '';
  };
  xdg.configFile."zsh/rc.d/shutdown.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias shutdown="/usr/bin/sudo /sbin/shutdown -h now"
    '';
  };
  xdg.configFile."fish/rc.d/shutdown.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias shutdown "/usr/bin/sudo /sbin/shutdown -h now"
    '';
  };
}
