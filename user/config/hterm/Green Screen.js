/*
 * Inspired by, but not exactly following, the Base16 "Green Screen"
 * scheme:
 *
 *     https://github.com/chriskempson/base16-unclaimed-schemes/blob/master/greenscreen.yaml
 */
black         = "#000000";
red           = "#002200";
green         = "#003300";
yellow        = "#004400";
blue          = "#005500";
magenta       = "#006600";
cyan          = "#007700";
white         = "#00ee00";
brightBlack   = "#001100";
brightRed     = "#008800";
brightGreen   = "#009900";
brightYellow  = "#00aa00";
brightBlue    = "#00bb00";
brightMagenta = "#00cc00";
brightCyan    = "#00dd00";
brightWhite   = "#00ff00";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", white);
t.prefs_.set("background-color", black);

t.prefs_.set("cursor-color", "rgba(0, 238, 0, 0.4)"); // white @ 40%

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink",          true);
t.prefs_.set("enable-bold",           true);
t.prefs_.set("enable-bold-as-bright", true);
