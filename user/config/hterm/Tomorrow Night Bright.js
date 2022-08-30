/*
 * https://github.com/chriskempson/tomorrow-theme/blob/master/Xdefaults/XresourceTomorrowNightBright
 */
black         = "#000000";
red           = "#d54e53";
green         = "#b9ca4a";
yellow        = "#e78c45";
blue          = "#7aa6da";
magenta       = "#c397d8";
cyan          = "#70c0b1";
white         = "#969896";
brightBlack   = "#424242";
brightRed     = "#d54e53";
brightGreen   = "#b9ca4a";
brightYellow  = "#e7c547";
brightBlue    = "#7aa6da";
brightMagenta = "#c397d8";
brightCyan    = "#70c0b1";
brightWhite   = "#eaeaea";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", "#eaeaea");
t.prefs_.set("background-color", "#000000");

t.prefs_.set("cursor-color", "#424242");

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink", true);
t.prefs_.set("enable-bold",  true);
