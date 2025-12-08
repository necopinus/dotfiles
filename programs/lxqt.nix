{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
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
    lxqt.xdg-desktop-portal-lxqt
    wayvnc
    wl-clip-persist
  ];

  qt.platformTheme.name = "lxqt";

  xdg.dataFile = {
    "themes/Adwaita".source = ../third-party/labwc-adwaita/Adwaita;
    "themes/Adwaita-dark".source = ../third-party/labwc-adwaita/Adwaita-dark;
  };

  wayland.windowManager.labwc = {
    enable = true;

    autostart = [
      # Probably unnecessary, but why leave Weston running if I'm not
      # using it?
      #
      "systemctl --user stop weston.service weston.socket"

      # Persist clipboard content after originating app closes
      #
      "wl-clip-persist --clipboard regular &"

      # VNC connection
      #
      "wayvnc 0.0.0.0 &"
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
