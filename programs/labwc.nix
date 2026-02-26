{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    labwc-gtktheme
  ];

  # Themes
  #
  xdg.dataFile = {
    "themes/Adwaita".source = ../third-party/labwc-adwaita/Adwaita;
    "themes/Adwaita-dark".source = ../third-party/labwc-adwaita/Adwaita-dark;
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
        ${pkgs.swaybg}/bin/swaybg -i "$(find -L ${config.xdg.dataHome}/backgrounds -type f | sort --random-sort | head -1)" &
      ''
      #"${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &"
      #"${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 &"
    ];

    menu = [
      {
        menuId = "root-menu";
        items = [
          #{separator = {label = "Applications";};}
          #{
          #  menuId = "pipe-menu";
          #  label = "Launch";
          #  execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --pipemenu --no-duplicates";
          #}
          #{
          #  menuId = "client-list-combined-menu";
          #  label = "Running";
          #}
          {
            label = "Chromium";
            action = {
              name = "Execute";
              command = "${config.programs.chromium.finalPackage}/bin/chromium-browser";
            };
          }
          {
            label = "Obsidian";
            action = {
              name = "Execute";
              command = "${pkgs.obsidian}/bin/obsidian --disable-gpu";
            };
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
          #{separator = {label = "Applications";};}
          #{
          #  menuId = "pipe-menu";
          #  label = "Launch";
          #  execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --pipemenu --no-duplicates";
          #}
          #{
          #  menuId = "client-list-combined-menu";
          #  label = "Running";
          #}
          {separator = {};}
          {
            menuId = "root-menu";
            label = "System";
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
