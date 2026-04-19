{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    dconf2nix

    #### Fonts ####
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji

    #### Additional wallpapers ####
    #
    # NOTE: These need to be explicitly included in home.packages in
    # order to show up in the GNOME Control Center
    #
    pantheon.elementary-wallpapers
    pop-wallpapers
  ];

  # Needed to force font cache to be rebuilt
  #
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      emoji = ["Noto Emoji"];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Sans Mono"
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
  xdg.mimeApps.enable = true;

  # No-frills theme configuration
  #
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme.name = "Adwaita";
    cursorTheme.name = "Adwaita";
    iconTheme.name = "Adwaita";
    font = {
      name = "Noto Sans";
      size = 10;
    };

    # Silence GTK4 warning, which doesn't really apply to me anyway
    # because I'm just trying to force Adwaita
    #
    gtk4.theme = null;
  };

  # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
  #
  dconf.settings = with lib.hm.gvariant; {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/spacex-81773.jpg";
      picture-uri-dark = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/spacex-81773.jpg";
      primary-color = "#000000";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      clock-show-seconds = true;
      overlay-scrolling = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };

    "org/gnome/desktop/privacy" = {
      recent-files-max-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-enabled = false;
      picture-options = "zoom";
      picture-uri = "file://${pkgs.pop-wallpapers}/share/backgrounds/pop/spacex-81773.jpg";
      primary-color = "#000000";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/nautilus/list-view" = {
      use-tree-view = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/Ptyxis" = {
      default-profile-uuid = "2d7007695ddd91580b6e8ab069e127b2";
      profile-uuids = ["2d7007695ddd91580b6e8ab069e127b2"];
      interface-style = "dark";
      scrollbar-policy = "never";
    };

    "org/gnome/Ptyxis/Profiles/2d7007695ddd91580b6e8ab069e127b2" = {
      palette = "Gruvbox";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "nothing";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
    };
  };

  # Fixes for various GNOME environment issues that can randomly happen;
  # see:
  #
  #   https://github.com/nix-community/home-manager/pull/7949#issuecomment-3434867383
  #   https://github.com/systemd/systemd/issues/32423#issuecomment-2907893187
  #   https://wiki.archlinux.org/title/Systemd/User#Re-using_the_shell_login_environment
  #   https://noah.meyerhans.us/2020/07/07/setting-environment-variables-for-gnome-session/
  #
  xdg.configFile = {
    #"systemd/user.conf".text = ''
    #  [Manager]
    #  ManagerEnvironment=SYSTEMD_ENVIRONMENT_GENERATOR_PATH=${config.home.homeDirectory}/.config/systemd/user-environment-generators:/run/systemd/user-environment-generators:/etc/systemd/user-environment-generators:/usr/local/lib/systemd/user-environment-generators:/usr/lib/systemd/user-environment-generators
    #'';
    #"systemd/user-environment-generators/10-home-manager" = {
    #  executable = true;
    #  text = ''
    #    #!/bin/sh
    #    env -i -- $SHELL --login -c env | grep -vE '^(_|SHLVL|PWD|OLDPWD)='
    #  '';
    #};
    "systemd/user/org.gnome.Shell@wayland.service.d/path.conf".text = ''
      [Service]
      Environment=PATH=${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
    '';
  };

  #xdg.configFile."bash/rc.d/dbus-update-activation-environment.sh" = {
  #  enable = config.programs.bash.enable;
  #  text = ''
  #    if [[ $(pgrep --uid $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) dbus-daemon | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -gt 0 ]]; then
  #      dbus-update-activation-environment \
  #        PATH="$PATH" \
  #        XDG_CONFIG_DIRS="$XDG_CONFIG_DIRS" \
  #        XDG_DATA_DIRS="$XDG_DATA_DIRS"
  #    fi
  #  '';
  #};
  #xdg.configFile."zsh/rc.d/dbus-update-activation-environment.sh" = {
  #  enable = config.programs.zsh.enable;
  #  text = ''
  #    if [[ $(pgrep --uid $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) dbus-daemon | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -gt 0 ]]; then
  #      dbus-update-activation-environment \
  #        PATH="$PATH" \
  #        XDG_CONFIG_DIRS="$XDG_CONFIG_DIRS" \
  #        XDG_DATA_DIRS="$XDG_DATA_DIRS"
  #    fi
  #  '';
  #};
  #xdg.configFile."fish/rc.d/dbus-update-activation-environment.fish" = {
  #  enable = config.programs.fish.enable;
  #  text = ''
  #    if test $(pgrep --uid $(${pkgs.uutils-coreutils-noprefix}/bin/id -u) dbus-daemon | ${pkgs.uutils-coreutils-noprefix}/bin/wc -l) -gt 0
  #      dbus-update-activation-environment \
  #        PATH="$PATH" \
  #        XDG_CONFIG_DIRS="$XDG_CONFIG_DIRS" \
  #        XDG_DATA_DIRS="$XDG_DATA_DIRS"
  #    end
  #  '';
  #};

  # Hide extraneous system ViM desktop entry
  #
  # NOTE: We have to do this using xdg.dataFile rather than
  # xdg.desktopEntries because .desktop files in ~/.nix-profile don't
  # mask system-level .desktop files
  #
  xdg.dataFile."applications/vim.desktop".text = ''
    [Desktop Entry]
    Name=Vim
    NoDisplay=true
    Hidden=true
  '';
}
