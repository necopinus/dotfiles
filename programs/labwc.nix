{
  config,
  pkgs,
  ...
}: {
  # Themes
  #
  xdg.dataFile = {
    "themes/Adwaita".source = ../third-party/labwc-adwaita/Adwaita;
    "themes/Adwaita-dark".source = ../third-party/labwc-adwaita/Adwaita-dark;
  };

  # Cargo-culted from Google's /usr/local/bin/enable_gfxstream on 2025-12-09
  #
  home.sessionVariables = {
    MESA_LOADER_DRIVER_OVERRIDE = "zink";
    VK_ICD_FILENAMES = "/usr/share/vulkan/icd.d/gfxstream_vk_icd.json";
    MESA_VK_WSI_DEBUG = "sw,linear";
    XWAYLAND_NO_GLAMOR = 1;
    LIBGL_KOPPER_DRI2 = 1;
  };

  wayland.windowManager.labwc = {
    enable = true;

    environment = [
      "XCURSOR_THEME=Adwaita"
      "XCURSOR_SIZE=24"
      "XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"

      # Run headless
      #
      "WLR_BACKENDS=headless"
      "WLR_LIBINPUT_NO_DEVICES=1"
    ];

    autostart = [
      ''
        ${pkgs.swaybg}/bin/swaybg -i "$(find ${config.xdg.dataHome}/backgrounds -type f | sort --random-sort | head -1)" &
      ''
      "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &"
      "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 &"
    ];

    menu = [
      {
        menuId = "root-menu";
        items = [
          {separator = {label = "Applications";};}
          {
            menuId = "pipe-menu";
            label = "Launch";
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --pipemenu --icons --no-duplicates";
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
          {separator = {label = "Window";};}
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
          {separator = {label = "Applications";};}
          {
            menuId = "pipe-menu";
            label = "Launch";
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --pipemenu --icons --no-duplicates";
          }
          {
            menuId = "client-list-combined-menu";
            label = "Running";
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
      keyboard = {default = true;};
    };
  };
}
