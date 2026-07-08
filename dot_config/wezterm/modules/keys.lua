-- ============================================================================
-- Non-theme keybindings. Additive (config.keys = config.keys or {} + insert) so
-- this composes with the theme picker keybind installed by modules/theme.lua,
-- regardless of require order.
--
-- The CTRL+SHIFT+T theme picker deliberately lives in modules/theme.lua (it
-- needs apply_theme), not here — that avoids a require cycle.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    config.keys = config.keys or {}

    local keys = {
        -- Jump between shell prompts in the scrollback (needs OSC 133 shell integration)
        { key = "UpArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
        { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },
        -- Reorder tabs
        { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
        { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.MoveTabRelative(1) },
        -- Insert a literal newline (multi-line input in Claude Code and other TUIs)
        { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x0a") },
        -- Fuzzy-pick a URL visible on screen and open it in the browser
        {
            key = "u",
            mods = "CTRL|SHIFT",
            action = wezterm.action.QuickSelectArgs({
                label = "open url",
                patterns = { "https?://\\S+" },
                action = wezterm.action_callback(function(window, pane)
                    local url = window:get_selection_text_for_pane(pane)
                    if url ~= "" then
                        wezterm.open_with(url)
                    end
                end),
            }),
        },
    }

    for _, k in ipairs(keys) do
        table.insert(config.keys, k)
    end
end

return M
