local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- tab bar config
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- font config
config.font_size = 14.0

-- color scheme:
config.color_scheme = 'Catppuccin Macchiato'

wezterm.plugin.require("https://github.com/nekowinston/wezterm-bar").apply_to_config(config, {
    position = "bottom",
    max_width = 32,
    dividers = "slant_right", -- or "slant_left", "arrows", "rounded", false
    indicator = {
      leader = {
        enabled = true,
        off = " ",
        on = " ",
      },
      mode = {
        enabled = true,
        names = {
          resize_mode = "RESIZE",
          copy_mode = "VISUAL",
          search_mode = "SEARCH",
        },
      },
    },
    tabs = {
      numerals = "arabic", -- or "roman"
      pane_count = "superscript", -- or "subscript", false
      brackets = {
        active = { "", ":" },
        inactive = { "", ":" },
      },
    },
    clock = { -- note that this overrides the whole set_right_status
      enabled = true,
      format = "%H:%M", -- use https://wezfurlong.org/wezterm/config/lua/wezterm.time/Time/format.html
    },
  })

return config