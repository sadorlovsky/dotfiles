-- ============================================================================
-- General config: static global knobs (window, rendering, behaviour, bell).
-- Tab-bar knobs live in modules/tabbar.lua; theme-driven appearance lives in
-- modules/theme.lua.
-- ============================================================================

local M = {}

function M.apply(config)
    config.automatically_reload_config = true
    config.window_close_confirmation = "NeverPrompt"
    config.window_decorations = "RESIZE"
    config.default_cursor_style = "SteadyBar"
    -- config.macos_window_background_blur = 50

    -- Rendering / performance
    config.front_end = "WebGpu" -- Metal on macOS; revert to "OpenGL" if anything looks off
    config.max_fps = 120

    -- Behaviour
    config.scrollback_lines = 20000 -- default is 3500
    config.switch_to_last_active_tab_when_closing_tab = true

    -- Subtle visual bell instead of an audible beep
    config.audible_bell = "Disabled"
    config.visual_bell = {
        fade_in_duration_ms = 75,
        fade_out_duration_ms = 75,
        target = "CursorColor",
    }
end

return M
