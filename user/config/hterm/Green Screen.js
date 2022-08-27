/*
 * Inspired by, but not exactly following, the Base16 "Green Screen"
 * scheme:
 *
 *     https://github.com/chriskempson/base16-unclaimed-schemes/blob/master/greenscreen.yaml
 */
black         = "#000000";

red           = "#003000";
green         = "#003e00";
yellow        = "#004c00";
blue          = "#005a00";
magenta       = "#006800";
cyan          = "#007600";

white         = "#00dd00";
brightBlack   = "#002200";

brightRed     = "#008900";
brightGreen   = "#009700";
brightYellow  = "#00a500";
brightBlue    = "#00b300";
brightMagenta = "#00c100";
brightCyan    = "#00cf00";

brightWhite   = "#00ff00";

t.prefs_.set("color-palette-overrides", [
	      black,       red,       green,       yellow,       blue,       magenta,       cyan,       white,
	brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite
]);

t.prefs_.set("foreground-color", "#00ee00");
t.prefs_.set("background-color", black);

t.prefs_.set("cursor-color", "rgba(0, 238, 0, 0.4)"); // #00ee00 @ 40%

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink",          true);
t.prefs_.set("enable-bold",           true);
t.prefs_.set("enable-bold-as-bright", true);
