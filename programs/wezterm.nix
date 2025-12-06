{
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;

    extraConfig = ''
      -- Init boilerplate
      --
      local wezterm = require "wezterm"
      local config = {}

      -- OS detection
      --
      local is_linux   <const> = wezterm.target_triple:find("linux")   ~= nil
      local is_macos   <const> = wezterm.target_triple:find("darwin")  ~= nil
      local is_windows <const> = wezterm.target_triple:find("windows") ~= nil

      -- Set font
      --
      config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
      if is_macos then
        config.font_size = 12.0
      else
        config.font_size = 10.0
      end
      config.line_height = 1.2

      -- Fix color rendering on macOS
      --
      if is_macos then
        config.front_end = "WebGpu"
      end

      -- Color scheme
      --
      config.color_scheme = "GruvboxLightMedium"
      config.colors = wezterm.color.load_scheme("${config.xdg.configHome}/wezterm/colors/" .. config.color_scheme .. ".toml")
      config.inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 1.0
      }

      -- Default window setup
      --
      config.initial_rows = 32
      config.initial_cols = 128

      config.use_fancy_tab_bar = false
      config.tab_max_width = 64
      config.default_cursor_style = "BlinkingBar"
      config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

      if is_macos then
        config.window_padding = {
          top = "4.5pt",
          right = "8pt",
          bottom = "3pt",
          left = "8pt"
        }
        config.window_frame = {
          border_top_height = "4.5pt",
          border_right_width = 0,
          border_bottom_height = 0,
          border_left_width = 0,

          border_top_color = config.colors.tab_bar.background,
          border_right_color = config.colors.background,
          border_bottom_color = config.colors.background,
          border_left_color = config.colors.background
        }
      else
        config.window_padding = {
          top = "6pt",
          right = "6pt",
          bottom = "6pt",
          left = "6pt"
        }

        config.tab_bar_style = {
          window_hide = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_minimize .. " " }
          },
          window_hide_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[4] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_minimize .. " " }
          },
          window_maximize = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_maximize .. " " }
          },
          window_maximize_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[3] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_maximize .. " " }
          },
          window_close = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_close .. " " }
          },
          window_close_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[2] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_close .. " " }
          },
        }
      end

      -- Launch fish by default (stub used to work around systems where
      -- /etc/passwd can't be modified)
      --
      config.default_prog = { "${pkgs.fish}/bin/fish", "-l" }

      -- Return config
      --
      return config
    '';

    colorSchemes = {
      GruvboxLightMedium = {
        foreground = "#282828";
        background = "#fbf1c7";

        cursor_fg = "none";
        cursor_bg = "#7c6f64";
        cursor_border = "#7c6f64";
        compose_cursor = "#af3a03";

        selection_fg = "none";
        selection_bg = "#d5c4a1";

        ansi = [
          "#fbf1c7"
          "#cc241d"
          "#98971a"
          "#d79921"
          "#458588"
          "#b16286"
          "#689d6a"
          "#7c6f64"
        ];
        brights = [
          "#928374"
          "#9d0006"
          "#79740e"
          "#b57614"
          "#076678"
          "#8f3f71"
          "#427b58"
          "#3c3836"
        ];

        scrollbar_thumb = "#ebdbb2";
        split = "#7c6f64";

        copy_mode_active_highlight_fg = {Color = "#fbf1c7";};
        copy_mode_active_highlight_bg = {Color = "#7c6f64";};
        copy_mode_inactive_highlight_fg = {Color = "#3c3836";};
        copy_mode_inactive_highlight_bg = {Color = "#d5c4a1";};

        quick_select_label_fg = {Color = "#fbf1c7";};
        quick_select_label_bg = {Color = "#98971a";};
        quick_select_match_fg = {Color = "#fbf1c7";};
        quick_select_match_bg = {Color = "#d79921";};

        input_selector_label_fg = {Color = "#fbf1c7";};
        input_selector_label_bg = {Color = "#3c3836";};

        launcher_label_fg = {Color = "#fbf1c7";};
        launcher_label_bg = {Color = "#3c3836";};

        tab_bar = {
          background = "#fbf1c7";

          active_tab = {
            bg_color = "#a89984";
            fg_color = "#fbf1c7";
            intensity = "Bold";
          };

          inactive_tab = {
            bg_color = "#fbf1c7";
            fg_color = "#928374";
          };
          inactive_tab_hover = {
            bg_color = "#ebdbb2";
            fg_color = "#282828";
          };

          new_tab = {
            bg_color = "#fbf1c7";
            fg_color = "#504945";
          };
          new_tab_hover = {
            bg_color = "#458588";
            fg_color = "#fbf1c7";
            intensity = "Bold";
          };
        };
      };
    };
  };
}
