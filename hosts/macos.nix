{
  config,
  pkgs,
  ...
}: {
  # Disable nix-darwin's management of the nix binary, as I'm using
  # determinate-nix
  #
  nix.enable = false;

  # Ensure that shell completions work correctly
  #
  environment.pathsToLink = [
    "/share/bash-completion"
    "/share/fish"
    "/share/zsh"
  ];

  # Use Touch ID with sudo (in all situations)
  #
  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    # This *looks* like it should supress hint messages, but doesn't...
    #
    #   https://docs.brew.sh/Brew-Bundle-and-Brewfile?pubDate=20251207#advanced-brewfiles
    #
    extraConfig = ''
      ENV["HOMEBREW_NO_ENV_HINTS"] = "1"
    '';

    casks = [
      "adobe-creative-cloud"
      "calibre" # Version in nixpkgs marked as broken
      "doppler-app"
      "google-drive"
      "handbrake-app" # Version in nixpkgs marked as broken
      "makemkv"
      {
        name = "obsidian";
        greedy = true; # App core doesn't actually get auto-updated
      }
      "proton-drive"
      "protonvpn"
      "qflipper"
      "qobuz-downloader"
      "scroll-reverser" # Version in nixpkgs flagged as "damaged" by macOS, won't open
      "signal"
      "stellarium" # Version in nixpkgs marked as broken
      "tresorit"
      "vlc"
      "wireshark-chmodbpf" # Wireshark helper driver (only used by hackenv)
      "yubico-yubikey-manager"
    ];
  };

  # Fonts
  #
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji
  ];

  # macOS configuration
  #
  networking = {
    computerName = "MacBook Pro";
    hostName = "macbook-pro";
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      allowSigned = true;
      allowSignedApp = true;
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      _HIHideMenuBar = false;

      AppleMetricUnits = 1;
      AppleMeasurementUnits = "Centimeters";
      AppleTemperatureUnit = "Celsius";
      AppleICUForce24HourTime = true;

      NSAutomaticPeriodSubstitutionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;

      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.forceClick" = true;
    };

    WindowManager.EnableTiledWindowMargins = false;

    controlcenter.BatteryShowPercentage = true;

    dock = {
      autohide = true;
      tilesize = 128;
      largesize = 128;
      mineffect = "scale";
      mru-spaces = false;
      orientation = "right";
      showAppExposeGestureEnabled = true;

      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;

      persistent-apps = [
        {app = "/System/Applications/Apps.app";}
        {app = "/Users/${config.system.primaryUser}/Applications/Home Manager Apps/Brave Browser.app";}
        {app = "/Users/${config.system.primaryUser}/Applications/Home Manager Apps/WezTerm.app";}
        {app = "/Users/${config.system.primaryUser}/Applications/Home Manager Apps/Zed.app";}
      ];
      persistent-others = [
        {
          folder = {
            path = "/Users/${config.system.primaryUser}/Applications/Brave Browser Apps.localized";
            showas = "grid";
          };
        }
        {
          folder = {
            path = "/Users/${config.system.primaryUser}/Downloads";
            showas = "grid";
          };
        }
      ];
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = false;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = false;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
    };

    loginwindow.GuestEnabled = false;

    magicmouse.MouseButtonMode = "TwoButton";

    menuExtraClock = {
      Show24Hour = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
      ShowSeconds = true;
    };

    screencapture.location = "~/Downloads";

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 5;
    };

    trackpad = {
      Clicking = true;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadPinch = true;
      TrackpadRightClick = true;
      TrackpadRotate = true;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    universalaccess = {
      reduceMotion = true;
      reduceTransparency = true;
    };

    CustomUserPreferences = {
      # a.k.a. "Apple Global Domain"
      #
      NSGlobalDomain = {
        SLSMenuBarUseBlurredAppearance = true;

        AppleLanguages = ["en-US"];
        AppleLocale = "en_US";
        AppleFirstWeekday = {gregorian = 2;};
        AppleICUDateFormatStrings = {"1" = "y-MM-dd";};
        AppleICUNumberSymbols = {
          "0" = ".";
          "1" = " "; # "\U202f" is a non-breaking space
          "10" = ".";
          "17" = " "; # "\U202f" is a non-breaking space
        };

        "com.apple.sound.uiaudio.enabled" = 0;
      };

      "com.apple.AdLib".allowApplePersonalizedAdvertising = false;

      "com.apple.assistant.support" = {
        "Assistant Enabled" = true;
        "Dictation Enabled" = true;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.Photos" = {
        IPXDefaultAutoplayVideos = false;
        showHolidayCalendarEvents = true;
      };

      "com.apple.Siri" = {
        StatusMenuVisible = false;
      };

      "com.apple.systemuiserver" = {
        menuExtras = [];
      };

      "com.apple.TextEdit" = {
        RichText = false;
        CheckGrammarWithSpelling = true;
        SmartLinks = true;
        DataDetectors = true;
        CheckSpellingAsYouTypeEnabledInRichTextOnly = true;
        AlwaysLightBackground = true;
      };

      "com.apple.universalaccess".showWindowTitlebarIcons = true;

      "com.google.drivefs.settings".PromptToBackupDevices = false;

      "com.pilotmoon.scroll-reverser" = {
        InvertScrollingOn = true;
        ReverseTrackpad = false;
      };

      # Not sure how to apply these settings without also losing my
      # license data...
      #
      # "dk.tacit.desktop"."/dk/tacit/desktop/" = {
      #   "foldersync/" = {
      #     always_show_tray_icon = false;
      #     start_minimized_to_tray = false;
      #     close_to_tray = false;
      #
      #     sync_transfer_threads = 1;
      #
      #     backup_folder = "/Users/${config.system.primaryUser}/data/backups/FolderSync/Desktop/";
      #   };
      # };

      "fr.handbrake.HandBrake" = {
        HBLastDestinationDirectoryURL = "/Users/${config.system.primaryUser}/Downloads";
        HBShowOpenPanelAtLaunch = false;
      };

      "jp.tmkk.XLD" = {
        DarkModeSupport = true;
        SUEnableAutomaticChecks = false;
      };

      "org.videolan.vlc".SUEnableAutomaticChecks = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
