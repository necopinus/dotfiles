{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    dictionaries = with pkgs; [hunspellDictsChromium.en_US];
  };

  xdg = {
    # The Android VM also doesn't support user namespaces (needed for
    # Chromium's sandbox to work); the `--test-type` flag suppresses
    # the resulting warning message
    #
    #   https://stackoverflow.com/questions/44429624/chromium-headless-remove-no-sandbox-notification
    #
    # FIXME: Check if this is still necessary after each Android
    # release!
    #
    desktopEntries = {
      "chromium-browser" = {
        categories = [
          "Network"
          "WebBrowser"
        ];
        comment = "Access the Internet";
        exec = "${pkgs.chromium}/bin/chromium --no-sandbox --test-type %U";
        icon = "chromium";
        mimeType = [
          "application/pdf"
          "application/rdf+xml"
          "application/rss+xml"
          "application/xhtml+xml"
          "application/xhtml_xml"
          "application/xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/webp"
          "text/html"
          "text/xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chromium"
        ];
        name = "Chromium";
        type = "Application";
        startupNotify = true;
        terminal = false;
        settings = {
          GenericName = "Web Browser";
          StartupWMClass = "chromium-browser";
        };
        actions = {
          new-window = {
            name = "New Window";
            exec = "${pkgs.chromium}/bin/chromium --no-sandbox --test-type";
          };
          new-private-window = {
            name = "New Incognito Window";
            exec = "${pkgs.chromium}/bin/chromium --incognito --no-sandbox --test-type";
          };
        };
      };
    };

    configFile = {
      "bash/rc.d/chromium.sh".text = ''
        alias chromium="${pkgs.chromium}/bin/chromium --no-sandbox --test-type"
        alias chromium-browser="${pkgs.chromium}/bin/chromium-browser --no-sandbox --test-type"
      '';
      "fish/rc.d/.fish".text = ''
        alias chromium "${pkgs.chromium}/bin/chromium --no-sandbox --test-type"
        alias chromium-browser "${pkgs.chromium}/bin/chromium-browser --no-sandbox --test-type"
      '';
      "zsh/rc.d/chromium.sh".text = ''
        alias chromium="${pkgs.chromium}/bin/chromium --no-sandbox --test-type"
        alias chromium-browser="${pkgs.chromium}/bin/chromium-browser --no-sandbox --test-type"
      '';
    };

    # Set Chromium as the default browser
    #
    mimeApps = {
      defaultApplications = {
        "application/x-extension-htm" = ["chromium-browser.desktop"];
        "application/x-extension-html" = ["chromium-browser.desktop"];
        "application/x-extension-shtml" = ["chromium-browser.desktop"];
        "application/x-extension-xht" = ["chromium-browser.desktop"];
        "application/x-extension-xhtml" = ["chromium-browser.desktop"];
        "application/xhtml+xml" = ["chromium-browser.desktop"];
        "text/html" = ["chromium-browser.desktop"];
        "x-scheme-handler/chrome" = ["chromium-browser.desktop"];
        "x-scheme-handler/http" = ["chromium-browser.desktop"];
        "x-scheme-handler/https" = ["chromium-browser.desktop"];
      };
      associations.added = {
        "application/pdf" = ["chromium-browser.desktop"];
        "application/rdf+xml" = ["chromium-browser.desktop"];
        "application/rss+xml" = ["chromium-browser.desktop"];
        "application/x-extension-htm" = ["chromium-browser.desktop"];
        "application/x-extension-html" = ["chromium-browser.desktop"];
        "application/x-extension-shtml" = ["chromium-browser.desktop"];
        "application/x-extension-xht" = ["chromium-browser.desktop"];
        "application/x-extension-xhtml" = ["chromium-browser.desktop"];
        "application/xhtml+xml" = ["chromium-browser.desktop"];
        "application/xhtml_xml" = ["chromium-browser.desktop"];
        "application/xml" = ["chromium-browser.desktop"];
        "text/html" = ["chromium-browser.desktop"];
        "text/xml" = ["chromium-browser.desktop"];
        "x-scheme-handler/chrome" = ["chromium-browser.desktop"];
        "x-scheme-handler/http" = ["chromium-browser.desktop"];
        "x-scheme-handler/https" = ["chromium-browser.desktop"];
      };
    };
  };
}
