{pkgs, ...}: {
  home.packages = with pkgs; [
    lxqt.lxqt-panel
    lxqt.pcmanfm-qt
  ];

  wayland.windowManager.labwc = {
    enable = true;

    autostart = [
      "${pkgs.wayvnc}/bin/wayvnc &"
      "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &"
    ];

    environment = [
      "XCURSOR_THEME=Adwaita"
      "XCURSOR_SIZE=24"
      "XDG_CURRENT_DESKTOP=labwc:wlroots"
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

      # FIXME: These are bad and need to go away
      #
      "WLR_RENDERER=pixman"
      "ZED_ALLOW_EMULATED_GPU=1"
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
            execute = "${pkgs.labwc-menu-generator}/bin/labwc-menu-generator --pipemenu --terminal-prefix ${pkgs.wezterm}/bin/wezterm";
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
}
