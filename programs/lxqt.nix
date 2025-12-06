{pkgs, ...}: {
  home.packages = with pkgs; [
    lxqt.lximage-qt
    lxqt.lxqt-about
    lxqt.lxqt-archiver
    lxqt.lxqt-config
    lxqt.lxqt-menu-data
    lxqt.lxqt-notificationd
    #lxqt.lxqt-panel
    lxqt.lxqt-runner
    lxqt.lxqt-session
    lxqt.lxqt-themes
    lxqt.lxqt-wayland-session
    lxqt.pcmanfm-qt
    lxqt.qlipper
    lxqt.qps
    lxqt.screengrab
    lxqt.xdg-desktop-portal-lxqt
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

    "lxqt/themes/LXQt-Brave".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Brave;
    "lxqt/themes/LXQt-Carbonite".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Carbonite;
    "lxqt/themes/LXQt-Dust".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Dust;
    "lxqt/themes/LXQt-Human".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Human;
    "lxqt/themes/LXQt-Illustrious".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Illustrious;
    "lxqt/themes/LXQt-Noble".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Noble;
    "lxqt/themes/LXQt-Tribute".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Tribute;
    "lxqt/themes/LXQt-Wine".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Wine;
    "lxqt/themes/LXQt-Wise".source = ../third-party/lxqt-themes-lxcolors/themes/LXQt-Wise;
    "lxqt/palettes" = {
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
      "${pkgs.swaybg}/bin/swaybg --color 464139 --image ${pkgs.pop-wallpapers}/share/backgrounds/pop/sean-afnan-244576.jpg --mode fill --output '*' &"
      "${pkgs.lxqt.pcmanfm-qt}/bin/pcmanfm-qt --desktop &"
      "${pkgs.lxqt.lxqt-panel}/bin/lxqt-panel &"
      "${pkgs.lxqt.lxqt-notificationd}/bin/lxqt-notificationd &"
      "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular &"

      # VNC connection
      #
      "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 &"
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
              command = "${pkgs.wezterm}/bin/wezterm";
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
        name = "Shiki-Nouveau-Wisedust";
        font = {"@weight" = "bold";};
        cornerRadius = 0;
        dropShadows = true;
      };
    };
  };
}
