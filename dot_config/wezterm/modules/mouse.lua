-- ============================================================================
-- Mouse bindings: triple-click selects a whole command's output (needs OSC 133
-- shell integration), plus mouse_reporting=true mirrors of the default select
-- gestures so selection works even when the app enables mouse reporting
-- (e.g. Claude Code fullscreen). The single-click "Up" mirror also opens a
-- hyperlink under the cursor on a plain click.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    config.mouse_bindings = {
        {
            event = { Down = { streak = 3, button = "Left" } },
            mods = "NONE",
            action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
        },
        -- Selection without Shift even when the app enables mouse reporting
        -- (e.g. Claude Code fullscreen): mirror the default select gestures.
        {
            event = { Down = { streak = 1, button = "Left" } },
            mods = "NONE",
            mouse_reporting = true,
            action = wezterm.action.SelectTextAtMouseCursor("Cell"),
        },
        {
            event = { Drag = { streak = 1, button = "Left" } },
            mods = "NONE",
            mouse_reporting = true,
            action = wezterm.action.ExtendSelectionToMouseCursor("Cell"),
        },
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            mouse_reporting = true,
            action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("PrimarySelection"),
        },
        {
            event = { Down = { streak = 2, button = "Left" } },
            mods = "NONE",
            mouse_reporting = true,
            action = wezterm.action.SelectTextAtMouseCursor("Word"),
        },
        {
            event = { Down = { streak = 3, button = "Left" } },
            mods = "NONE",
            mouse_reporting = true,
            action = wezterm.action.SelectTextAtMouseCursor("Line"),
        },
    }
end

return M
