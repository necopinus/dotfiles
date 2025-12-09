{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    labwc-menu-generator
    libnotify # Needed for lxqt-qdbus
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
    pipewire # Needed for xdg-desktop-portal-wlr
    wayvnc
    wl-clip-persist
  ];

  qt.platformTheme.name = "lxqt";

  xdg = {
    portal = {
      config = {
        common = {
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

      # Expose service files to systemd
      #
      #   https://github.com/nix-community/home-manager/issues/4922#issuecomment-1914642319
      #
      "systemd/user/filter-chain.service".source = "${pkgs.pipewire}/share/systemd/user/filter-chain.service";
      "systemd/user/pipewire-pulse.service".source = "${pkgs.pipewire}/share/systemd/user/pipewire-pulse.service";
      "systemd/user/pipewire-pulse.socket".source = "${pkgs.pipewire}/share/systemd/user/pipewire-pulse.socket";
      "systemd/user/pipewire.service".source = "${pkgs.pipewire}/share/systemd/user/pipewire.service";
      "systemd/user/pipewire.socket".source = "${pkgs.pipewire}/share/systemd/user/pipewire.socket";
      "systemd/user/xdg-desktop-portal-lxqt.service".source = "${pkgs.lxqt.xdg-desktop-portal-lxqt}/share/systemd/user/xdg-desktop-portal-lxqt.service";
      "systemd/user/xdg-desktop-portal-wlr.service".source = "${pkgs.xdg-desktop-portal-wlr}/share/systemd/user/xdg-desktop-portal-wlr.service";

      # LXQt continually updates its own configuration files (KDE is
      # similar - maybe it's a Qt thing?), which makes it impossible to
      # keep them in the Nix store. Instead, we just symlink them
      # directly from ./artifacts. This is a bit messy, since it means
      # that LXQt will continually "update" the repository, but at least
      # allows for things to be kept in version control.
      #
      "lxqt".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/artifacts/config/lxqt";
      "pcmanfm-qt".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/artifacts/config/pcmanfm-qt";
      "screengrab".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/artifacts/config/screengrab";
    };
    dataFile = {
      # LXQt config files that are (relatively) safe to link directly
      "libfm-qt/terminals.list".source = ../artifacts/local/share/libfm-qt/terminals.list;

      # Themes
      # 
      "themes/Adwaita".source = ../third-party/labwc-adwaita/Adwaita;
      "themes/Adwaita-dark".source = ../third-party/labwc-adwaita/Adwaita-dark;
    };
  };
  home.file = {
    ".icons/default/index.theme".source = ../artifacts/icons/default/index.theme;
    ".Xdefaults".source = ../artifacts/Xresources;
    ".Xresources".source = ../artifacts/Xresources;
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

      # XDG desktop portal startup will fail unless the systemd
      # environment is updated first. Attempt to recover from this.
      #
      # Startup is also excrutiatingly slow - on the order of a couple
      # minutes. I have no idea why things take so long
      # 
      "systemctl --user stop xdg-*-portal*.service xdg-permission-store.service"
      "dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user start xdg-desktop-portal.service"
    ];

    environment = [
      "XCURSOR_THEME=Adwaita"
      "XCURSOR_SIZE=24"
      #"XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"

      # Needed for lab-sensible-terminal
      #
      "TERMINAL=wezterm start --cwd ${config.home.homeDirectory}"

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
              command = "lab-sensible-terminal";
            };
          }
          {separator = {label = "Applications";};}
          {
            menuId = "pipe-menu";
            label = "Launch";
            execute = "labwc-menu-generator --pipemenu --icons --no-duplicates --terminal-prefix 'wezterm start --cwd . -e'";
          }
          {
            menuId = "client-list-combined-menu";
            label = "Running";
          }
          {separator = {};}
          {
            label = "Exit";
            action = {name = "Exit";};
          }
        ];
      }
      {
        menuId = "client-menu";
        items = [
          {
            label = "Minimize";
            action = {name = "Iconify";};
          }
          {separator = {label = "Toggles";};}
          {
            label = "Shade";
            action = {name = "ToggleShade";};
          }
          {
            label = "Maximize";
            action = {name = "ToggleMaximize";};
          }
          {
            label = "Always on Top";
            action = {name = "ToggleAlwaysOnTop";};
          }
          {separator = {};}
          {
            label = "Close";
            action = {name = "Close";};
          }
        ];
      }
    ];

    rc = {
      theme = {
        name = "Adwaita-dark";
        dropShadows = "yes";
      };
      keyboard = {
        default = true;
        keybind = [
          {
            "@key" = "A-k";
            action = {
              "@name" = "Execute";
              "@command" = "lxqt-runner";
            };
          }
          {
            "@key" = "A-Return";
            action = {
              "@name" = "Execute";
              "@command" = "wezterm start --cwd ${config.home.homeDirectory}";
            };
          }
        ];
      };
    };
  };
}
