-- ============================================================================
-- SSH domains: auto-generate a WezTerm ssh_domain for every host in your
-- ~/.ssh/config, so `wezterm connect <host>` works for each host you already
-- defined — with WezTerm's own tab/pane handling over the connection.
--   Connect:  `wezterm connect <host>`, or the launcher (Ctrl+Shift+L → SSH).
-- Wildcard stanzas (Host *, Host foo-*) are skipped — they aren't real targets.
-- Wrapped in pcall so a malformed ssh config can never break the whole config.
-- ============================================================================

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    local domains = {}
    local ok, hosts = pcall(wezterm.enumerate_ssh_hosts)
    if ok and hosts then
        for host, _ in pairs(hosts) do
            if not host:find("[*?]") then
                table.insert(domains, {
                    name = host,
                    remote_address = host,
                    multiplexing = "None", -- plain ssh; no remote mux server needed
                    assume_shell = "Posix", -- enables shell-integration niceties
                })
            end
        end
    end
    config.ssh_domains = domains
end

return M
