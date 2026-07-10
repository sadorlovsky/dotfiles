-- ============================================================================
-- WezTerm config — thin entry point. Each concern lives in a module under
-- modules/ (see the M.apply(config) contract, mirrored from snippets/). The
-- theme module computes the active theme and drives the tab bar internally.
-- ============================================================================

local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}

require("modules.general").apply(config)
require("modules.links").apply(config)
require("modules.mouse").apply(config)
require("modules.keys").apply(config)
require("modules.ssh").apply(config) -- ssh_domains generated from ~/.ssh/config
require("modules.theme").apply(config) -- computes the active theme; wires tabbar

-- ============================================================================
-- Optional add-ons (dormant). Uncomment to enable; see the snippet's header for
-- the cheatsheet. Panes/splits, vim-aware navigation, and workspaces:
-- ============================================================================
-- require("snippets.panes_workspaces").apply(config)

return config
