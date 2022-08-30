/*
 * https://github.com/chriskempson/tomorrow-theme/blob/master/Xdefaults/XresourceTomorrowNight
 */
black         = "#002451";
red           = "#ff9da4";
green         = "#d1f1a9";
yellow        = "#ffc58f";
blue          = "#bbdaff";
magenta       = "#ebbbff";
cyan          = "#99ffff";
white         = "#7285b7";
brightBlack   = "#00346e";
brightRed     = "#ff9da4";
brightGreen   = "#d1f1a9";
brightYellow  = "#ffeead";
brightBlue    = "#bbdaff";
brightMagenta = "#ebbbff";
brightCyan    = "#99ffff";
brightWhite   = "#ffffff";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", "#ffffff");
t.prefs_.set("background-color", "#002451");

t.prefs_.set("cursor-color", "#003f8e");

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink", true);
t.prefs_.set("enable-bold",  true);
