-- ============================================================================
-- Themes: persistence, the theme table, auto light/dark themes, the
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

    -- Same as Synthwave, but with the Kung Fury "Hackerman" background image.
    {
        name = "Hackerman",
        color_scheme = "Nord (Gogh)",
        font = wezterm.font_with_fallback({
            { family = "Fairfax Hax", weight = "Regular" },
            "JetBrains Mono",
        }),
        font_size = 18,
        background = {
            {
                source = {
                    File = wezterm.config_dir .. "/hackerman.jpg",
                },
                width = "Cover",
                height = "Cover",
                hsb = { brightness = 0.45 },
            },
            {
                source = {
                    Color = "#0c0016",
                },
                width = "100%",
                height = "100%",
                opacity = 0.85,
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

    -- Minimal synthwave: solid background, no image, no transparency. A single
    -- "auto" theme (auto = true) — one picker entry — whose palette follows the
    -- OS light/dark setting. theme_overrides() resolves variants[appearance] at
    -- apply time, so the Dark/Light faces never appear as separate choices.
    {
        name = "Synthwave Minimal",
        auto = true,
        variants = {
            -- DARK face.
            Dark = {
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
            -- LIGHT face.
            Light = {
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
        },
    },
}

local DEFAULT_THEME = "Synthwave"

-- Build a lookup + turn a theme into a table of config overrides.
local themes_by_name = {}
for _, t in ipairs(themes) do
    themes_by_name[t.name] = t
end

-- The OS light/dark setting, plus its coarse "Dark"/"Light" key for indexing an
-- auto theme's variants. Falls back to Dark when there's no GUI (e.g. mux
-- server). Defined here because theme_overrides() below closes over them.
local function current_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance() -- "Light" / "Dark" / *HighContrast
    end
    return "Dark"
end

local function appearance_key()
    return current_appearance():find("Dark") and "Dark" or "Light"
end

local function theme_overrides(name)
    local t = themes_by_name[name] or themes_by_name[DEFAULT_THEME]
    -- Auto themes carry variants.Dark / variants.Light; pick the one matching
    -- the current OS appearance. Plain themes use their own top-level fields.
    if t.auto then
        t = t.variants[appearance_key()]
    end
    return {
        color_scheme = t.color_scheme,
        font = t.font,
        font_size = t.font_size,
        background = t.background,
        colors = t.colors,
        window_frame = t.window_frame,
    }
end

-- A stable string fingerprint of a theme's overrides, used by the reload handler
-- to decide whether anything actually changed. It walks the table with sorted
-- keys (deterministic output) and collapses non-serialisable values — fonts are
-- userdata — to a constant marker. Colours, background image path/opacity/
-- brightness, and tab-bar colours are all plain data and thus captured; the one
-- blind spot is font-family edits (open a fresh window for those).
local function fingerprint(v, out)
    local t = type(v)
    if t == "table" then
        local keys = {}
        for k in pairs(v) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        out[#out + 1] = "{"
        for _, k in ipairs(keys) do
            out[#out + 1] = tostring(k) .. "="
            fingerprint(v[k], out)
            out[#out + 1] = ";"
        end
        out[#out + 1] = "}"
    elseif t == "userdata" or t == "function" then
        out[#out + 1] = "<" .. t .. ">"
    else
        out[#out + 1] = tostring(v)
    end
end

local function overrides_signature(name)
    local out = {}
    fingerprint(theme_overrides(name), out)
    return table.concat(out)
end

-- ----------------------------------------------------------------------------
-- Auto themes follow the OS light/dark setting: an entry with auto = true holds
-- variants.Dark / variants.Light and shows as a single picker choice. The face
-- is resolved by theme_overrides()/appearance_key() (above); is_auto() just
-- reports whether a saved selection is one of these OS-following themes.
-- ----------------------------------------------------------------------------

local function is_auto(name)
    local t = themes_by_name[name]
    return t ~= nil and t.auto == true
end

-- Which tab-bar system a theme uses. Only "Clean" is plugin-backed; everything
-- else (including auto themes, which are never Clean) uses the built-in fancy
-- bar. Crossing this boundary requires a full config reload (see
-- modules/tabbar.lua for why).
local function bar_system(name)
    return (name == "Clean") and "plugin" or "fancy"
end

-- Apply a theme to a window at runtime and persist the *selection* (not the
-- resolved face), so an auto pick keeps following the OS afterwards.
local function apply_theme(window, pane, name)
    local prev = read_saved_theme() or DEFAULT_THEME
    save_theme(name)
    local shown = is_auto(name) and (name .. " · auto") or name
    window:toast_notification("WezTerm", "Theme: " .. shown, nil, 2000)
    if bar_system(prev) ~= bar_system(name) then
        -- Crossing the Clean<->fancy boundary needs a fresh Lua state; the full
        -- reload rebuilds the base config, and window-config-reloaded then
        -- re-pushes the appearance overrides.
        window:perform_action(wezterm.action.ReloadConfiguration, pane)
    else
        -- Same tab-bar system: swap appearance in place, flash-free. Record the
        -- signature we're about to push so the reload it triggers is recognised
        -- as already-applied and the handler below no-ops instead of redoing it.
        local applied = wezterm.GLOBAL.applied_sig or {}
        applied[tostring(window:window_id())] = overrides_signature(name)
        wezterm.GLOBAL.applied_sig = applied
        window:set_config_overrides(theme_overrides(name))
    end
end

-- ----------------------------------------------------------------------------
-- Public surface
-- ----------------------------------------------------------------------------

M.DEFAULT_THEME = DEFAULT_THEME
M.read_saved_theme = read_saved_theme
M.apply_theme = apply_theme

local function theme_choices()
    local choices = {}
    for _, t in ipairs(themes) do
        choices[#choices + 1] = { label = t.name, id = t.name }
    end
    return choices
end

function M.apply(config)
    -- 1. Determine the active theme up front (auto themes resolve their face
    --    inside theme_overrides, so the raw name is all we track here).
    local active = read_saved_theme() or DEFAULT_THEME

    -- 2. Wire the tab bar for that theme BEFORE applying appearance overrides
    --    (the plugin, when used, mutates config at load time). Auto themes are
    --    never "Clean", so the raw name is enough for the plugin decision.
    require("modules.tabbar").apply(config, active)

    -- 3. Apply the last-picked theme's appearance (persists across restarts).
    for k, v in pairs(theme_overrides(active)) do
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

    -- 6. Re-push the persisted theme's appearance on EVERY config reload — a
    --    file save (CTRL+SHIFT+R), or the automatic reload wezterm does when the
    --    OS appearance flips. This is what makes edits to this file actually show
    --    up on reload: set_config_overrides values persist on top of the freshly
    --    rebuilt base config, so without re-pushing them the window keeps
    --    rendering the *previous* overrides (the bug where only a brand-new
    --    window picked up changes). Rebuilding from theme_overrides(saved) reads
    --    the just-reloaded theme table, so edits and the current OS appearance
    --    both apply.
    --
    --    Loop/no-op guard: compare a content signature of the desired overrides
    --    against what's already applied (kept in wezterm.GLOBAL, which survives
    --    reloads). Different -> re-push and record; same -> do nothing. The
    --    reload our own set_config_overrides triggers recomputes the same
    --    signature and stops there. Unlike a one-shot echo flag this can't
    --    desync when a push emits no reload (identical overrides), so no edit is
    --    ever swallowed on the following reload.
    wezterm.on("window-config-reloaded", function(window)
        local wid = tostring(window:window_id())
        local saved = read_saved_theme() or DEFAULT_THEME
        local want = overrides_signature(saved)
        local applied = wezterm.GLOBAL.applied_sig or {}
        if applied[wid] == want then
            return
        end
        applied[wid] = want
        wezterm.GLOBAL.applied_sig = applied
        window:set_config_overrides(theme_overrides(saved))
    end)
end

return M
