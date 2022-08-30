/*
 * https://github.com/chriskempson/tomorrow-theme/blob/master/Xdefaults/XresourceTomorrowNight
 */
black         = "#1d1f21";
red           = "#cc6666";
green         = "#b5bd68";
yellow        = "#de935f";
blue          = "#81a2be";
magenta       = "#b294bb";
cyan          = "#8abeb7";
white         = "#969896";
brightBlack   = "#282a2e";
brightRed     = "#cc6666";
brightGreen   = "#b5bd68";
brightYellow  = "#f0c674";
brightBlue    = "#81a2be";
brightMagenta = "#b294bb";
brightCyan    = "#8abeb7";
brightWhite   = "#c5c8c6";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", "#c5c8c6");
t.prefs_.set("background-color", "#1d1f21");

t.prefs_.set("cursor-color", "#373b41");

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink", true);
t.prefs_.set("enable-bold",  true);
