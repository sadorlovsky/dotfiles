-- ============================================================================
-- Selection & links: QuickSelect one-key-copy targets and clickable hyperlink
-- rules.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    -- QuickSelect (CTRL+SHIFT+Space): extra one-key-copy targets on top of the defaults
    config.quick_select_patterns = {
        "[0-9a-f]{7,40}", -- git hashes
        "\\b\\d{1,3}(\\.\\d{1,3}){3}\\b", -- IPv4 addresses
    }

    -- Clickable links: built-in rules + bare email addresses
    config.hyperlink_rules = wezterm.default_hyperlink_rules()
    table.insert(config.hyperlink_rules, {
        regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
        format = "mailto:$0",
    })
end

return M
