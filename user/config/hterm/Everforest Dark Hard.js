/*
 * Everforest Light Hard color scheme. See:
 *
 *     https://gist.github.com/sainnhe/6432f83181c4520ea87b5211fed27950
 */
black         = "#4b565c";
red           = "#e67e80";
green         = "#a7c080";
yellow        = "#dbbc7f";
blue          = "#7fbbb3";
magenta       = "#d699b6";
cyan          = "#83c092";
white         = "#d3c6aa";
brightBlack   = "#4b565c";
brightRed     = "#e67e80";
brightGreen   = "#a7c080";
brightYellow  = "#dbbc7f";
brightBlue    = "#7fbbb3";
brightMagenta = "#d699b6";
brightCyan    = "#83c092";
brightWhite   = "#d3c6aa";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", white);
t.prefs_.set("background-color", "#2b3339"); // Slightly darker background

t.prefs_.set("cursor-color", "rgba(167, 192, 128, 0.4)"); // green @ 40%

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink",          true);
t.prefs_.set("enable-bold",           true);
t.prefs_.set("enable-bold-as-bright", true);
