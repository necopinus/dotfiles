{pkgs, ...}: {
  home.packages = with pkgs; [
    lxqt.lxqt-panel
    lxqt.pcmanfm-qt
  ];

  wayland.windowManager.labwc = {
    enable = true;

    autostart = [
      "${pkgs.wayvnc}/bin/wayvnc &"
    ];

    environment = [
      "XDG_CURRENT_DESKTOP=labwc:wlroots"
      "XKB_DEFAULT_LAYOUT=us"
    ];

    menu = [
      {
        menuId = "root-menu";
        items = [
          {
            label = "Terminal";
            action = {
              name = "Execute";
              command = "${pkgs.wezterm}/bin/wezterm";
            };
          }
          {separator = {};}
          {
            menuId = "pipe-menu";
            label = "Applications";
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator";
          }
          {separator = {};}
          {
            label = "Exit";
            action = {name = "Exit";};
          }
        ];
      }
    ];

    #rc = {};
  };

  services.wayvnc = {
    enable = true;
    settings.address = "0.0.0.0";
  };
  services.wl-clip-persist.enable = true;
}
