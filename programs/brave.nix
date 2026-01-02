{pkgs, ...}: {
  home.packages = [pkgs.brave];

  xdg.mimeApps = {
    defaultApplications = {
      "application/x-extension-htm" = ["brave-browser.desktop"];
      "application/x-extension-html" = ["brave-browser.desktop"];
      "application/x-extension-shtml" = ["brave-browser.desktop"];
      "application/x-extension-xht" = ["brave-browser.desktop"];
      "application/x-extension-xhtml" = ["brave-browser.desktop"];
      "application/xhtml+xml" = ["brave-browser.desktop"];
      "text/html" = ["brave-browser.desktop"];
      "x-scheme-handler/chrome" = ["brave-browser.desktop"];
      "x-scheme-handler/http" = ["brave-browser.desktop"];
      "x-scheme-handler/https" = ["brave-browser.desktop"];
    };
    associations.added = {
      "application/pdf" = ["brave-browser.desktop"];
      "application/rdf+xml" = ["brave-browser.desktop"];
      "application/rss+xml" = ["brave-browser.desktop"];
      "application/x-extension-htm" = ["brave-browser.desktop"];
      "application/x-extension-html" = ["brave-browser.desktop"];
      "application/x-extension-shtml" = ["brave-browser.desktop"];
      "application/x-extension-xht" = ["brave-browser.desktop"];
      "application/x-extension-xhtml" = ["brave-browser.desktop"];
      "application/xhtml+xml" = ["brave-browser.desktop"];
      "application/xhtml_xml" = ["brave-browser.desktop"];
      "application/xml" = ["brave-browser.desktop"];
      "text/html" = ["brave-browser.desktop"];
      "text/xml" = ["brave-browser.desktop"];
      "x-scheme-handler/chrome" = ["brave-browser.desktop"];
      "x-scheme-handler/http" = ["brave-browser.desktop"];
      "x-scheme-handler/https" = ["brave-browser.desktop"];
    };
  };
}
