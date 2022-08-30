/*
 * https://github.com/chriskempson/tomorrow-theme/blob/master/Xdefaults/XresourceTomorrow
 */
black         = "#4d4d4c";
red           = "#c82829";
green         = "#718c00";
yellow        = "#f5871f";
blue          = "#4271ae";
magenta       = "#8959a8";
cyan          = "#3e999f";
white         = "#efefef";
brightBlack   = "#8e908c";
brightRed     = "#c82829";
brightGreen   = "#718c00";
brightYellow  = "#eab700";
brightBlue    = "#4271ae";
brightMagenta = "#8959a8";
brightCyan    = "#3e999f";
brightWhite   = "#ffffff";

/*
 * Note that the black and white color slots are reversed here. This is
 * a quick-and-dirty way of ensuring that (most) terminal apps (which
 * tend to assume a light-on-dark color scheme) look good.
 */
t.prefs_.set("color-palette-overrides", [
	      white,       red,       green,       yellow,       blue,       magenta,       cyan,       black,
	brightWhite, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightBlack
]);

t.prefs_.set("foreground-color", "#4d4d4c");
t.prefs_.set("background-color", "#ffffff");

t.prefs_.set("cursor-color", "#d6d6d6");

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink", true);
t.prefs_.set("enable-bold",  true);
