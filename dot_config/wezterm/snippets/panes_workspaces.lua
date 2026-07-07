-- ============================================================================
-- Panes, splits & workspaces  —  DORMANT (not loaded unless you enable it)
-- ----------------------------------------------------------------------------
-- This file does nothing on its own. To turn it ON, uncomment the line at the
-- bottom of wezterm.lua:
--
--     require("snippets.panes_workspaces").apply(config)
--
-- To turn it OFF again, comment that one line and reload WezTerm.
--
-- CHEATSHEET  (LEADER = Ctrl+A: press & release, THEN press the next key)
--   LEADER  |        split pane to the right (vertical divider)
--   LEADER  -        split pane below (horizontal divider)
--   Ctrl+h/j/k/l     move focus left/down/up/right between panes
--                    (falls through to nvim's own splits if nvim is focused)
--   LEADER  x        close the current pane
--   LEADER  z        zoom / un-zoom the current pane (temporary fullscreen)
--   LEADER  r        resize mode: tap h/j/k/l to resize, Esc or q to leave
--   LEADER  p        pick a pane by letter and jump to it
--   LEADER  s        pick a pane and swap it with the active one
--   LEADER  w        switch workspace (fuzzy menu)
--   LEADER  n        create a new workspace (prompts for a name)
--   LEADER  e        rename the current tab
--   LEADER  Ctrl+a   send a literal Ctrl+A to the shell (jump to line start)
--
-- Concepts:
--   * pane      = a split region inside one window (many terminals side by side)
--   * workspace = a named set of windows/tabs/panes ("a desktop per project")
-- ============================================================================

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
    -- Leader: a tmux-style prefix key. Ctrl+A is the classic pick, but it shadows
    -- the shell's "beginning of line" — use `LEADER Ctrl+A` for that, or change the
    -- leader here (e.g. { key = "Space", mods = "CTRL" }).
    config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

    -- Dim panes that aren't focused so the active one stands out.
    config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

    -- Ctrl+h/j/k/l moves between WezTerm panes, but forwards the key to (n)vim when
    -- vim is the focused process, so vim moves between ITS splits. Delete this
    -- helper (and the four vim_nav(...) lines below) if you don't use vim splits.
    local function vim_nav(key, direction)
        return {
            key = key,
            mods = "CTRL",
            action = wezterm.action_callback(function(win, pane)
                local proc = (pane:get_foreground_process_name() or ""):lower()
                if proc:find("n?vim") then
                    win:perform_action(act.SendKey({ key = key, mods = "CTRL" }), pane)
                else
                    win:perform_action(act.ActivatePaneDirection(direction), pane)
                end
            end),
        }
    end

    local extra_keys = {
        -- Splits
        { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

        -- Pane management
        { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
        { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
        { key = "p", mods = "LEADER", action = act.PaneSelect({ alphabet = "asdfghjkl" }) },
        { key = "s", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },

        -- Enter modal resize mode (see key_tables.resize below)
        { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize", one_shot = false }) },

        -- Send a literal Ctrl+A to the shell (since the leader ate it)
        { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },

        -- Workspaces
        { key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
        {
            key = "n",
            mods = "LEADER",
            action = act.PromptInputLine({
                description = "New workspace name:",
                action = wezterm.action_callback(function(win, pane, line)
                    if line and line ~= "" then
                        win:perform_action(act.SwitchToWorkspace({ name = line }), pane)
                    end
                end),
            }),
        },
        {
            key = "e",
            mods = "LEADER",
            action = act.PromptInputLine({
                description = "Rename tab:",
                action = wezterm.action_callback(function(win, _, line)
                    if line then
                        win:active_tab():set_title(line)
                    end
                end),
            }),
        },

        -- Vim-aware pane navigation
        vim_nav("h", "Left"),
        vim_nav("j", "Down"),
        vim_nav("k", "Up"),
        vim_nav("l", "Right"),
    }

    -- Append to the existing keys (don't clobber the theme picker etc.)
    config.keys = config.keys or {}
    for _, k in ipairs(extra_keys) do
        table.insert(config.keys, k)
    end

    -- Modal resize table: after `LEADER r`, tap h/j/k/l repeatedly; Esc/q to exit.
    config.key_tables = config.key_tables or {}
    config.key_tables.resize = {
        { key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
        { key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
        { key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
        { key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "q", action = "PopKeyTable" },
    }

    -- Left status: surface LEADER / active key-table so modal state is visible.
    wezterm.on("update-status", function(window)
        local txt = ""
        if window:leader_is_active() then
            txt = " LEADER "
        end
        local kt = window:active_key_table()
        if kt then
            txt = " " .. kt:upper() .. " "
        end
        window:set_left_status(txt ~= "" and wezterm.format({
            { Foreground = { Color = "#fab387" } },
            { Text = txt },
        }) or "")
    end)
end

return M
