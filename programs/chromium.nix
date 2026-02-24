{pkgs, ...}: {
  programs.chromium = {
    enable = true;

    dictionaries = with pkgs; [hunspellDictsChromium.en_US];

    # Chromium doesn't work right with the Android VM's virtual GPU
    #
    commandLineArgs = ["--dsiable-gpu"];
  };

  # Set Chromium as the default browser
  #
  xdg.mimeApps = {
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
}
