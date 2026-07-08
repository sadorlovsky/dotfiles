-- ============================================================================
-- Themes: persistence, the theme table, minimal-family auto light/dark, the
-- runtime picker (CTRL+SHIFT+T), the command-palette entries, and the tab-bar
-- wiring. This is the tightly-coupled appearance cluster; everything here
-- revolves around the persisted theme selection.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

-- ----------------------------------------------------------------------------
-- Persistence: remember the last-picked theme across config reloads AND full
-- restarts by stashing its name in a tiny state file next to this config.
-- ----------------------------------------------------------------------------

local STATE_FILE = wezterm.config_dir .. "/.current-theme"

local function read_saved_theme()
    local f = io.open(STATE_FILE, "r")
    if not f then
        return nil
    end
    local name = f:read("l")
    f:close()
    if name and name ~= "" then
        return name
    end
    return nil
end

local function save_theme(name)
    local f = io.open(STATE_FILE, "w")
    if f then
        f:write(name)
        f:close()
    end
end

-- ----------------------------------------------------------------------------
-- Themes: each entry bundles the "appearance" bits (scheme, font, size,
-- background, tab bar colors). Switch between them at runtime via the picker.
-- ----------------------------------------------------------------------------

local themes = {
    -- The original synthwave look, extracted verbatim.
    {
        name = "Synthwave",
        color_scheme = "Nord (Gogh)",
        font = wezterm.font_with_fallback({
            { family = "Fairfax Hax", weight = "Regular" },
            "JetBrains Mono",
        }),
        font_size = 18,
        background = {
            {
                source = {
                    File = wezterm.config_dir .. "/synthwave-calm.png",
                },
                width = "100%",
                height = "100%",
                hsb = { brightness = 0.6 },
            },
            {
                source = {
                    Color = "#0c0016",
                },
                width = "100%",
                height = "100%",
                opacity = 0.78,
            },
        },
        colors = {
            tab_bar = {
                background = "#14001a",
                inactive_tab_edge = "none",
                active_tab = {
                    bg_color = "#14001a",
                    fg_color = "#c77dff",
                    intensity = "Bold",
                    italic = false,
                },
                inactive_tab = {
                    bg_color = "#14001a",
                    fg_color = "#6a3a8a",
                    italic = false,
                },
                inactive_tab_hover = {
                    bg_color = "#14001a",
                    fg_color = "#e0aaff",
                    italic = false,
                },
                new_tab = {
                    bg_color = "#14001a",
                    fg_color = "#6a3a8a",
                },
                new_tab_hover = {
                    bg_color = "#14001a",
                    fg_color = "#e0aaff",
                },
            },
        },
        -- Only used when use_fancy_tab_bar = true; harmless otherwise.
        window_frame = {
            font = wezterm.font_with_fallback({
                { family = "Fairfax Hax", weight = "Bold" },
                "JetBrains Mono",
            }),
            font_size = 18,
            active_titlebar_bg = "#14001a",
            inactive_titlebar_bg = "#14001a",
        },
    },

    -- A calmer, "less nerdy" theme: no background image, standard mono font,
    -- muted Tokyo Night palette. This is the only theme that uses the
    -- wezterm-bar plugin tab bar (see modules/tabbar.lua).
    {
        name = "Clean",
        color_scheme = "Tokyo Night",
        font = wezterm.font_with_fallback({
            "JetBrains Mono",
            "Fairfax Hax",
        }),
        font_size = 15,
        -- Solid color so it fully overrides the synthwave image when swapping.
        background = {
            {
                source = { Color = "#1a1b26" },
                width = "100%",
                height = "100%",
            },
        },
        colors = {
            tab_bar = {
                background = "#1a1b26",
                inactive_tab_edge = "none",
                active_tab = {
                    bg_color = "#1a1b26",
                    fg_color = "#7aa2f7",
                    intensity = "Bold",
                    italic = false,
                },
                inactive_tab = {
                    bg_color = "#1a1b26",
                    fg_color = "#565f89",
                    italic = false,
                },
                inactive_tab_hover = {
                    bg_color = "#1a1b26",
                    fg_color = "#c0caf5",
                    italic = false,
                },
                new_tab = {
                    bg_color = "#1a1b26",
                    fg_color = "#565f89",
                },
                new_tab_hover = {
                    bg_color = "#1a1b26",
                    fg_color = "#c0caf5",
                },
            },
        },
        -- Only used when use_fancy_tab_bar = true; harmless otherwise.
        window_frame = {
            font = wezterm.font_with_fallback({
                "JetBrains Mono",
                "Fairfax Hax",
            }),
            font_size = 16,
            active_titlebar_bg = "#1a1b26",
            inactive_titlebar_bg = "#1a1b26",
        },
    },

    -- Minimal synthwave, DARK: solid background, no image, no transparency.
    -- Part of the "minimal" family that auto-follows the OS appearance.
    {
        name = "Synthwave Minimal (dark)",
        color_scheme = "Catppuccin Mocha",
        font = wezterm.font_with_fallback({
            { family = "Fairfax Hax", weight = "Regular" },
            "JetBrains Mono",
        }),
        font_size = 18,
        background = {
            {
                source = { Color = "#1e1e2e" },
                width = "100%",
                height = "100%",
            },
        },
        colors = {
            tab_bar = {
                background = "#181825",
                inactive_tab_edge = "none",
                active_tab = {
                    bg_color = "#181825",
                    fg_color = "#cba6f7",
                    intensity = "Bold",
                    italic = false,
                },
                inactive_tab = {
                    bg_color = "#181825",
                    fg_color = "#6c7086",
                    italic = false,
                },
                inactive_tab_hover = {
                    bg_color = "#181825",
                    fg_color = "#f5c2e7",
                    italic = false,
                },
                new_tab = {
                    bg_color = "#181825",
                    fg_color = "#6c7086",
                },
                new_tab_hover = {
                    bg_color = "#181825",
                    fg_color = "#f5c2e7",
                },
            },
        },
        window_frame = {
            font = wezterm.font_with_fallback({
                { family = "Fairfax Hax", weight = "Bold" },
                "JetBrains Mono",
            }),
            font_size = 18,
            active_titlebar_bg = "#181825",
            inactive_titlebar_bg = "#181825",
        },
    },

    -- Minimal synthwave, LIGHT: solid light background, no image, no transparency.
    -- Part of the "minimal" family that auto-follows the OS appearance.
    {
        name = "Synthwave Minimal (light)",
        color_scheme = "Catppuccin Latte",
        font = wezterm.font_with_fallback({
            { family = "Fairfax Hax", weight = "Regular" },
            "JetBrains Mono",
        }),
        font_size = 18,
        background = {
            {
                source = { Color = "#eff1f5" },
                width = "100%",
                height = "100%",
            },
        },
        colors = {
            tab_bar = {
                background = "#e6e9ef",
                inactive_tab_edge = "none",
                active_tab = {
                    bg_color = "#e6e9ef",
                    fg_color = "#8839ef",
                    intensity = "Bold",
                    italic = false,
                },
                inactive_tab = {
                    bg_color = "#e6e9ef",
                    fg_color = "#8c8fa1",
                    italic = false,
                },
                inactive_tab_hover = {
                    bg_color = "#e6e9ef",
                    fg_color = "#ea76cb",
                    italic = false,
                },
                new_tab = {
                    bg_color = "#e6e9ef",
                    fg_color = "#8c8fa1",
                },
                new_tab_hover = {
                    bg_color = "#e6e9ef",
                    fg_color = "#ea76cb",
                },
            },
        },
        window_frame = {
            font = wezterm.font_with_fallback({
                { family = "Fairfax Hax", weight = "Bold" },
                "JetBrains Mono",
            }),
            font_size = 18,
            active_titlebar_bg = "#e6e9ef",
            inactive_titlebar_bg = "#e6e9ef",
        },
    },
}

local DEFAULT_THEME = "Synthwave"

-- Build a lookup + turn a theme into a table of config overrides.
local themes_by_name = {}
for _, t in ipairs(themes) do
    themes_by_name[t.name] = t
end

local function theme_overrides(name)
    local t = themes_by_name[name] or themes_by_name[DEFAULT_THEME]
    return {
        color_scheme = t.color_scheme,
        font = t.font,
        font_size = t.font_size,
        background = t.background,
        colors = t.colors,
        window_frame = t.window_frame,
    }
end

-- ----------------------------------------------------------------------------
-- Minimal family: these themes auto-follow the OS light/dark setting. Picking
-- either one enters "minimal-auto" mode; the OS then decides which face shows.
-- ----------------------------------------------------------------------------

local MINIMAL_DARK = "Synthwave Minimal (dark)"
local MINIMAL_LIGHT = "Synthwave Minimal (light)"

local function is_minimal(name)
    return name == MINIMAL_DARK or name == MINIMAL_LIGHT
end

local function current_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance() -- "Light" / "Dark" / *HighContrast
    end
    return "Dark"
end

-- Map a saved selection to the theme that should actually render right now.
-- Minimal selections follow the OS appearance; everything else is literal.
local function resolve_theme(name)
    if is_minimal(name) then
        if current_appearance():find("Dark") then
            return MINIMAL_DARK
        end
        return MINIMAL_LIGHT
    end
    return name
end

-- Which tab-bar system a (resolved) theme uses. Only "Clean" is plugin-backed;
-- everything else uses the built-in fancy bar. Crossing this boundary requires
-- a full config reload (see modules/tabbar.lua for why).
local function bar_system(name)
    return (resolve_theme(name) == "Clean") and "plugin" or "fancy"
end

-- Apply a theme to a window at runtime and persist the *selection* (not the
-- resolved variant), so a minimal pick keeps following the OS afterwards.
-- Colours/font/background switch instantly via set_config_overrides. If the
-- pick crosses the tab-bar-system boundary (into or out of "Clean"), trigger a
-- full ReloadConfiguration so the build-time branch rewires the correct bar
-- (a brief one-frame flash).
local function apply_theme(window, pane, name)
    local prev = read_saved_theme() or DEFAULT_THEME
    save_theme(name)
    local effective = resolve_theme(name)
    local applied = wezterm.GLOBAL.minimal_applied or {}
    applied[tostring(window:window_id())] = is_minimal(name) and effective or nil
    wezterm.GLOBAL.minimal_applied = applied
    window:set_config_overrides(theme_overrides(effective))
    local shown = is_minimal(name) and (effective .. " · auto") or name
    window:toast_notification("WezTerm", "Theme: " .. shown, nil, 2000)
    if bar_system(prev) ~= bar_system(name) then
        window:perform_action(wezterm.action.ReloadConfiguration, pane)
    end
end

-- ----------------------------------------------------------------------------
-- Public surface
-- ----------------------------------------------------------------------------

M.DEFAULT_THEME = DEFAULT_THEME
M.read_saved_theme = read_saved_theme
M.resolve_theme = resolve_theme
M.apply_theme = apply_theme

local function theme_choices()
    local choices = {}
    for _, t in ipairs(themes) do
        choices[#choices + 1] = { label = t.name, id = t.name }
    end
    return choices
end

function M.apply(config)
    -- 1. Determine the active (and resolved) theme up front.
    local active = read_saved_theme() or DEFAULT_THEME
    local resolved = resolve_theme(active)

    -- 2. Wire the tab bar for that theme BEFORE applying appearance overrides
    --    (the plugin, when used, mutates config at load time).
    require("modules.tabbar").apply(config, resolved)

    -- 3. Apply the last-picked theme's appearance (persists across restarts).
    for k, v in pairs(theme_overrides(resolved)) do
        config[k] = v
    end

    -- 4. Theme picker (fuzzy menu) — CTRL+SHIFT+T. Additive so it composes with
    --    modules/keys.lua regardless of require order.
    config.keys = config.keys or {}
    table.insert(config.keys, {
        key = "T",
        mods = "CTRL|SHIFT",
        action = wezterm.action.InputSelector({
            title = "Select Theme",
            fuzzy = true,
            choices = theme_choices(),
            action = wezterm.action_callback(function(window, pane, id, _label)
                if not id then
                    return
                end
                apply_theme(window, pane, id)
            end),
        }),
    })

    -- 5. Command palette (CTRL+SHIFT+P): one discoverable entry per theme.
    wezterm.on("augment-command-palette", function(_window, _pane)
        local entries = {}
        for _, t in ipairs(themes) do
            entries[#entries + 1] = {
                brief = "Theme: " .. t.name,
                action = wezterm.action_callback(function(win, pane)
                    apply_theme(win, pane, t.name)
                end),
            }
        end
        return entries
    end)

    -- 6. Auto light/dark: wezterm re-evaluates the config when the OS appearance
    --    flips, firing this event. If the active selection is a minimal theme,
    --    swap the window to the matching variant. The per-window guard in
    --    wezterm.GLOBAL (which survives reloads) prevents an infinite reload loop.
    wezterm.on("window-config-reloaded", function(window)
        local saved = read_saved_theme() or DEFAULT_THEME
        local wid = tostring(window:window_id())
        local applied = wezterm.GLOBAL.minimal_applied or {}
        if not is_minimal(saved) then
            if applied[wid] ~= nil then
                applied[wid] = nil
                wezterm.GLOBAL.minimal_applied = applied
            end
            return
        end
        local want = resolve_theme(saved)
        if applied[wid] == want then
            return
        end
        applied[wid] = want
        wezterm.GLOBAL.minimal_applied = applied
        window:set_config_overrides(theme_overrides(want))
    end)
end

return M
