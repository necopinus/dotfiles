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
    casks = [
      "adobe-creative-cloud"
      "calibre" # Version in nixpkgs marked as broken
      "claude"
      "discord" # Version in nixpkgs fails to install updates
      "doppler-app"
      "github"
      "google-drive"
      "handbrake-app" # Version in nixpkgs marked as broken
      "makemkv"
      "obsidian"
      "proton-drive"
      "proton-pass"
      "protonvpn"
      "qflipper"
      "qobuz-downloader"
      "reader"
      "scroll-reverser" # Version in nixpkgs flagged as "damaged" by macOS, won't open
      "signal"
      "stellarium" # Version in nixpkgs marked as broken
      "todoist-app"
      "tresorit"
      "vlc"
      "yubico-yubikey-manager"
    ];
  };

  # Fonts
  #
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji
  ];

  # macOS configuration
  #
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
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
        {app = "/Applications/Claude.app";}
        {app = "/Users/${config.system.primaryUser}/Applications/Home Manager Apps/WezTerm.app";}
      ];
      persistent-others = [
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
      TrackpadThreeFingerTapGesture = false;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    # CustomUserPreferences = {};
    # CustomSystemPreferences = {};
  };
}
