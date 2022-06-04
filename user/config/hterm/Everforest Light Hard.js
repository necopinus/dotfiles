/*
 * Everforest Light Hard color scheme. See:
 *
 *     https://gist.github.com/sainnhe/6432f83181c4520ea87b5211fed27950
 *
 * Background is taken from kepano's Obsidian port:
 *
 *     https://github.com/kepano/obsidian-minimal/blob/master/src/scss/color-schemes/everforest.scss#L32
 */
black         = "#5c6a72";
red           = "#f85552";
green         = "#8da101";
yellow        = "#dfa000";
blue          = "#3a94c5";
magenta       = "#df69ba";
cyan          = "#35a77c";
white         = "#fdf7e3";
brightBlack   = "#5c6a72";
brightRed     = "#f85552";
brightGreen   = "#8da101";
brightYellow  = "#dfa000";
brightBlue    = "#3a94c5";
brightMagenta = "#df69ba";
brightCyan    = "#35a77c";
brightWhite   = "#fdf7e3";

/*
 * Note that color-palette-overrides should go "black, red, ..., cyan,
 * white", but we flip the black and white values in order to make
 * things play nicer with Tmux, Zsh, and other tools that seem to be
 * configured to expect terminal with a dark background color.
 */
t.prefs_.set("color-palette-overrides", [
	      white,       red,       green,       yellow,       blue,       magenta,       cyan,       black,
	brightWhite, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightBlack
]);

t.prefs_.set("foreground-color", black);
t.prefs_.set("background-color", white);

t.prefs_.set("cursor-color", "rgba(140, 161, 1, 0.4)"); // green @ 40%

/*
 * Additional options. See:
 *
 *     https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/js/hterm_preference_manager.js
 */
t.prefs_.set("cursor-blink",          true);
t.prefs_.set("enable-bold",           true);
t.prefs_.set("enable-bold-as-bright", true);
