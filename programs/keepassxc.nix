{
  config,
  pkgs,
  ...
}: let
  proxyPath =
    if pkgs.stdenv.isDarwin
    then "/Applications/KeePassXC.app/Contents/MacOS/keepassxc-proxy"
    else "${pkgs.keepassxc}/bin/keepassxc-proxy";
in {
  programs.keepassxc = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then null
      else pkgs.keepassxc;

    autostart = pkgs.stdenv.isLinux;

    settings = {
      General = {
        AutoGeneratePasswordForNewEntries = true;
        UpdateCheckMessageShown = true;
      };
      Browser = {
        Enabled = true;
        SearchInAllDatabases = true;
        UpdateBinaryPath = false;
      };
      GUI = {
        ColorPasswords = true;
        MinimizeOnClose = true;
        MinimizeOnStartup = true;
        MinimizeToTray = pkgs.stdenv.isDarwin;
        MonospaceNotes = true;
        ShowTrayIcon = pkgs.stdenv.isDarwin;
        TrayIconApearance = "monochrome";
      };
      Security = {
        IconDownloadFallback = true;
        LockDatabaseIdle = false;
      };
      SSHAgent.Enabled = true;
    };
  };

  launchd.agents."org.keepassxc.KeePassXC" = {
    enable = pkgs.stdenv.isDarwin;
    config = {
      AssociatedBundleIdentifiers = "org.keepassxc.KeePassXC";
      Label = "org.keepassxc.KeePassXC";
      ProgramArguments = [
        "/Applications/KeePassXC.app/Contents/MacOS/KeePassXC"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/dev/null";
      StandardOutPath = "/dev/null";
    };
  };

  home.file = {
    "Library/Application Support/KeePassXC/keepassxc.ini" = {
      enable = pkgs.stdenv.isDarwin;
      source = config.xdg.configFile."keepassxc/keepassxc.ini".source;
    };
    "Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json" = {
      enable = pkgs.stdenv.isDarwin;
      text = ''
        {
          "allowed_origins": [
            "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/",
            "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
          ],
          "description": "KeePassXC integration with native messaging support",
          "name": "org.keepassxc.keepassxc_browser",
          "path": "${proxyPath}",
          "type": "stdio"
        }
      '';
    };
  };
}
