/*
 * https://github.com/chriskempson/tomorrow-theme/blob/master/Xdefaults/XresourceTomorrowNight
 */
black         = "#2d2d2d";
red           = "#f2777a";
green         = "#99cc99";
yellow        = "#f99157";
blue          = "#6699cc";
magenta       = "#cc99cc";
cyan          = "#66cccc";
white         = "#999999";
brightBlack   = "#393939";
brightRed     = "#f2777a";
brightGreen   = "#99cc99";
brightYellow  = "#ffcc66";
brightBlue    = "#6699cc";
brightMagenta = "#cc99cc";
brightCyan    = "#66cccc";
brightWhite   = "#cccccc";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", "#cccccc");
t.prefs_.set("background-color", "#2d2d2d");

t.prefs_.set("cursor-color", "#515151");

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink", true);
t.prefs_.set("enable-bold",  true);
