{pkgs, ...}: {
  home.packages = with pkgs; [
    labwc-gtktheme
    labwc-tweaks
    lxqt.lximage-qt
    lxqt.lxqt-about
    lxqt.lxqt-archiver
    lxqt.lxqt-config
    lxqt.lxqt-menu-data
    lxqt.lxqt-notificationd
    #lxqt.lxqt-panel
    lxqt.lxqt-runner
    lxqt.lxqt-themes
    lxqt.lxqt-wayland-session
    lxqt-panel-profiles
    lxqt.pcmanfm-qt
    lxqt.qlipper
    lxqt.qps
    lxqt.screengrab
    lxqt.xdg-desktop-portal-lxqt
    #menu-cache
  ];

  qt.platformTheme.name = "lxqt";

  xdg.dataFile = {
    "themes/Shiki-Brave".source = ../third-party/openbox-shiki-colors-themes/Shiki-Brave;
    "themes/Shiki-Dust".source = ../third-party/openbox-shiki-colors-themes/Shiki-Dust;
    "themes/Shiki-Human".source = ../third-party/openbox-shiki-colors-themes/Shiki-Human;
    "themes/Shiki-Illustrious".source = ../third-party/openbox-shiki-colors-themes/Shiki-Illustrious;
    "themes/Shiki-Noble".source = ../third-party/openbox-shiki-colors-themes/Shiki-Noble;
    "themes/Shiki-Wine".source = ../third-party/openbox-shiki-colors-themes/Shiki-Wine;
    "themes/Shiki-Wise".source = ../third-party/openbox-shiki-colors-themes/Shiki-Wise;

    "themes/Shiki-Nouveau-Humandust".source = ../third-party/shiki-nouveau-fall-colors/Shiki-Nouveau-Humandust;
    "themes/Shiki-Nouveau-Winedust".source = ../third-party/shiki-nouveau-fall-colors/Shiki-Nouveau-Winedust;
    "themes/Shiki-Nouveau-Wisedust".source = ../third-party/shiki-nouveau-fall-colors/Shiki-Nouveau-Wisedust;

    "themes/LXQt-Brave".source = ../third-party/lxqt-themes-lxcolors/LXQt-Brave;
    "themes/LXQt-Carbonite".source = ../third-party/lxqt-themes-lxcolors/LXQt-Carbonite;
    "themes/LXQt-Dust".source = ../third-party/lxqt-themes-lxcolors/LXQt-Dust;
    "themes/LXQt-Human".source = ../third-party/lxqt-themes-lxcolors/LXQt-Human;
    "themes/LXQt-Illustrious".source = ../third-party/lxqt-themes-lxcolors/LXQt-Illustrious;
    "themes/LXQt-Noble".source = ../third-party/lxqt-themes-lxcolors/LXQt-Noble;
    "themes/LXQt-Tribute".source = ../third-party/lxqt-themes-lxcolors/LXQt-Tribute;
    "themes/LXQt-Wine".source = ../third-party/lxqt-themes-lxcolors/LXQt-Wine;
    "themes/LXQt-Wise".source = ../third-party/lxqt-themes-lxcolors/LXQt-Wise;
    "palettes" = {
      source = ../third-party/lxqt-themes-lxcolors/palettes;
      recursive = true;
    };
  };

  wayland.windowManager.labwc = {
    enable = true;

    autostart = [
      # Probably unnecessary, but why leave Weston running if I'm not
      # using it?
      #
      "systemctl --user stop weston.service weston.socket"

      # Desktop environment
      #
      #"${pkgs.lxqt.pcmanfm-qt}/bin/pcmanfm-qt --desktop &"
      "${pkgs.lxqt.lxqt-panel}/bin/lxqt-panel &"
      "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &"

      # VNC connection
      #
      "${pkgs.wayvnc}/bin/wayvnc &"
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
