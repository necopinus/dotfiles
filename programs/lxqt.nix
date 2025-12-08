{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    labwc-menu-generator
    lxqt.lxqt-about
    lxqt.lxqt-archiver
    lxqt.lxqt-config
    lxqt.lxqt-menu-data
    lxqt.lxqt-notificationd
    lxqt.lxqt-panel
    lxqt.lxqt-runner
    lxqt.lxqt-session
    lxqt.lxqt-themes
    lxqt.lxqt-wayland-session
    lxqt.pcmanfm-qt
    lxqt.screengrab
    wayvnc
    wl-clip-persist
  ];

  qt.platformTheme.name = "lxqt";

  xdg = {
    portal = {
      config = {
        default = {
          "org.freedesktop.impl.portal.FileChooser" = "lxqt:gtk"; # From system lxqt-portals.conf
          "org.freedesktop.impl.portal.Inhibit" = "none"; # From system labwc-portals.conf
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
      extraPortals = with pkgs; [
        lxqt.xdg-desktop-portal-lxqt
        xdg-desktop-portal-wlr
      ];
    };

    configFile = {
      # Disable autostart entries; we don't use xdg.autostart because that
      # only allows us to ADD entries from existing packages, and masking
      # using the "hidden application" template file is more economical
      # anyway
      #
      "autostart/lxqt-xscreensaver-autostart.desktop".source = ../artifacts/local/share/applications/hidden.desktop;

      # Create autostart entries (for applications that don't supply their
      # own .desktop files)
      #
      "autostart/wayvnc.desktop".source = ../artifacts/config/autostart/wayvnc.desktop;
      "autostart/wl-clip-persist.desktop".source = ../artifacts/config/autostart/wl-clip-persist.desktop;
    };
    dataFile = {
      "themes/Adwaita".source = ../third-party/labwc-adwaita/Adwaita;
      "themes/Adwaita-dark".source = ../third-party/labwc-adwaita/Adwaita-dark;
    };
  };

  wayland.windowManager.labwc = {
    enable = true;

    autostart = [
      # The Android Debian VM agressively starts Weston, and there's no
      # way to disable this that I've found that doesn't involve making
      # (potentially fragile) edits to system files, so we just stop it
      # here as part of the labwc init process
      #
      "systemctl --user stop weston.service weston.socket"
    ];

    environment = [
      "XCURSOR_THEME=Adwaita"
      "XCURSOR_SIZE=24"
      #"XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"

      # Cargo-culted from Google's ~/weston.env on 2025-12-05
      #
      "MESA_LOADER_DRIVER_OVERRIDE=zink"
      "MESA_VK_WSI_DEBUG=sw,linear"
      "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json"
      "XWAYLAND_NO_GLAMOR=1"

      # Run headless
      #
      "WLR_BACKENDS=headless"
      "WLR_LIBINPUT_NO_DEVICES=1"
    ];

    menu = [
      {
        menuId = "root-menu";
        items = [
          {
            label = "Terminal";
            action = {
              name = "Execute";
              command = "wezterm start --cwd ${config.home.homeDirectory}";
            };
          }
          {separator = {};}
          {
            menuId = "pipe-menu";
            label = "Applications ...";
            execute = ''
              labwc-menu-generator --pipemenu --icons --no-duplicates --terminal-prefix "wezterm start --cwd . -e"
            '';
          }
          {
            menuId = "client-list-combined-menu";
            label = "Running ...";
          }
          {separator = {};}
          {
            label = "Exit";
            action = {name = "Exit";};
          }
        ];
      }
    ];

    rc = {
      theme = {
        name = "Adwaita-dark";
        dropShadows = "yes";
      };
    };
  };
}
