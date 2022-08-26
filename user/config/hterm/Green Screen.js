/*
 * Inspired by, but not exactly following, the Base16 "Green Screen"
 * scheme:
 *
 *     https://github.com/chriskempson/base16-unclaimed-schemes/blob/master/greenscreen.yaml
 */
black         = "#000000";
red           = "#001100";
green         = "#002200";
yellow        = "#003300";
blue          = "#004400";
magenta       = "#005500";
cyan          = "#006600";
white         = "#007700";
brightBlack   = "#008800";
brightRed     = "#009900";
brightGreen   = "#00aa00";
brightYellow  = "#00bb00";
brightBlue    = "#00cc00";
brightMagenta = "#00dd00";
brightCyan    = "#00ee00";
brightWhite   = "#00ff00";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", white);
t.prefs_.set("background-color", black);

t.prefs_.set("cursor-color", "rgba(0, 255, 0, 0.4)"); // brightWhite @ 40%

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink",          true);
t.prefs_.set("enable-bold",           true);
t.prefs_.set("enable-bold-as-bright", true);
