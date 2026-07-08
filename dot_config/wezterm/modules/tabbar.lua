-- ============================================================================
-- Tab bar. Static knobs shared by all themes, plus a per-theme branch:
--
--   * "Clean"    -> retro tab bar + the nekowinston/wezterm-bar plugin
--                   (slant dividers, clock, leader/mode indicator, arabic
--                    numerals, superscript pane count) — matches the old
--                    unmanaged ~/.wezterm.lua look.
--   * everything else (Synthwave family) -> built-in fancy tab bar, styled per
--                    theme via colors.tab_bar + window_frame.
--
-- WHY a build-time branch and not a runtime toggle:
--   use_fancy_tab_bar is a single GLOBAL boolean, and wezterm-bar registers
--   GLOBAL format-tab-title / update-status handlers via wezterm.on at config
--   load. window:set_config_overrides (the picker path) cannot un/re-register
--   those handlers, and format-tab-title is consulted by BOTH bar styles — so a
--   loaded plugin would corrupt the Synthwave fancy bar. The plugin is
--   therefore loaded ONLY when the active theme is "Clean".
--
--   Consequence: crossing the Clean<->Synthwave boundary needs a fresh Lua
--   state, i.e. a full config reload. modules/theme.lua's apply_theme triggers
--   ReloadConfiguration automatically on that crossing (a brief one-frame
--   flash). Switches WITHIN the Synthwave/minimal family never reload.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

function M.apply(config, active_theme_name)
    config.enable_tab_bar = true
    config.tab_max_width = 32 -- default is 16, which truncates longer titles
    config.show_close_tab_button_in_tabs = false
    config.hide_tab_bar_if_only_one_tab = true
    config.show_new_tab_button_in_tab_bar = false

    if active_theme_name == "Clean" then
        config.use_fancy_tab_bar = false
        -- The plugin colours its bar from the active color_scheme (Tokyo Night
        -- for Clean); each theme's colors.tab_bar becomes cosmetic here.
        -- First run clones the plugin repo from GitHub (needs network once).
        wezterm.plugin.require("https://github.com/nekowinston/wezterm-bar").apply_to_config(config, {
            position = "bottom",
            max_width = 32,
            dividers = "slant_right", -- or "slant_left", "arrows", "rounded", false
            indicator = {
                leader = {
                    enabled = true,
                    off = " ",
                    on = " ",
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
                format = "%H:%M",
            },
        })
    else
        config.use_fancy_tab_bar = true
        config.tab_bar_at_bottom = true
    end
end

return M
