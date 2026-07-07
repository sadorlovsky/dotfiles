local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- ============================================================================
-- Persistence: remember the last-picked theme across config reloads AND full
-- restarts by stashing its name in a tiny state file next to this config.
-- ============================================================================

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

-- ============================================================================
-- Themes: each entry bundles the "appearance" bits (scheme, font, size,
-- background, tab bar colors). Switch between them at runtime via the picker.
-- ============================================================================

local themes = {
    -- The original synthwave look, extracted verbatim.
    {
        name = "Synthwave",
        color_scheme = "Nord (Gogh)",
        font = wezterm.font_with_fallback({
            { family = "Fairfax Hax", weight = "Medium" },
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
    -- muted Tokyo Night palette.
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
            { family = "Fairfax Hax", weight = "Medium" },
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
            { family = "Fairfax Hax", weight = "Medium" },
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

-- ============================================================================
-- Minimal family: these themes auto-follow the OS light/dark setting. Picking
-- either one enters "minimal-auto" mode; the OS then decides which face shows.
-- ============================================================================

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

-- Apply a theme to a window at runtime and persist the *selection* (not the
-- resolved variant), so a minimal pick keeps following the OS afterwards.
local function apply_theme(window, name)
    save_theme(name)
    local effective = resolve_theme(name)
    local applied = wezterm.GLOBAL.minimal_applied or {}
    applied[tostring(window:window_id())] = is_minimal(name) and effective or nil
    wezterm.GLOBAL.minimal_applied = applied
    window:set_config_overrides(theme_overrides(effective))
    local shown = is_minimal(name) and (effective .. " · auto") or name
    window:toast_notification("WezTerm", "Theme: " .. shown, nil, 2000)
end

-- ============================================================================
-- General config
-- ============================================================================

config.automatically_reload_config = true
config.enable_tab_bar = true
config.tab_max_width = 32 -- default is 16, which truncates longer titles
config.show_close_tab_button_in_tabs = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
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

-- Triple-click selects a whole command's output (needs OSC 133 shell integration)
config.mouse_bindings = {
    {
        event = { Down = { streak = 3, button = "Left" } },
        mods = "NONE",
        action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    },
}

-- Apply the last-picked theme (persists across reloads/restarts), else default.
local ACTIVE_THEME = read_saved_theme() or DEFAULT_THEME
for k, v in pairs(theme_overrides(resolve_theme(ACTIVE_THEME))) do
    config[k] = v
end

-- ============================================================================
-- Theme picker (fuzzy menu) — CTRL+SHIFT+T
-- ============================================================================

local function theme_choices()
    local choices = {}
    for _, t in ipairs(themes) do
        choices[#choices + 1] = { label = t.name, id = t.name }
    end
    return choices
end

config.keys = {
    {
        key = "T",
        mods = "CTRL|SHIFT",
        action = wezterm.action.InputSelector({
            title = "Select Theme",
            fuzzy = true,
            choices = theme_choices(),
            action = wezterm.action_callback(function(window, _pane, id, _label)
                if not id then
                    return
                end
                apply_theme(window, id)
            end),
        }),
    },
    -- Jump between shell prompts in the scrollback (needs OSC 133 shell integration)
    { key = "UpArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
    { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },
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

-- ============================================================================
-- Command palette (CTRL+SHIFT+P, built in): add one entry per theme so themes
-- are discoverable there too, alongside the CTRL+SHIFT+T fuzzy picker.
-- ============================================================================

wezterm.on("augment-command-palette", function(_window, _pane)
    local entries = {}
    for _, t in ipairs(themes) do
        entries[#entries + 1] = {
            brief = "Theme: " .. t.name,
            action = wezterm.action_callback(function(win, _p)
                apply_theme(win, t.name)
            end),
        }
    end
    return entries
end)

-- ============================================================================
-- Auto light/dark: wezterm re-evaluates the config when the OS appearance
-- flips, firing this event. If the active selection is a minimal theme, swap
-- the window to the matching variant. The per-window guard in wezterm.GLOBAL
-- (which survives reloads) prevents an infinite reload loop.
-- ============================================================================

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

return config
