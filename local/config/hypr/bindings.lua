-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Workspace overview ("Mission Control"), via the hyprtasking plugin.
--
-- SUPER + A was unbound, so nothing is displaced: ALT+SHIFT+TAB keeps reverse alt-tab
-- and SUPER+TAB keeps "next workspace".
--
-- The plugin exposes a Lua namespace (hl.plugin.hyprtasking), which is how Hyprland 0.56
-- surfaces plugin dispatchers now. Two forms that do NOT work here, both failing silently:
--   * a plain string "hyprtasking:toggle" -- o.bind treats a string as a SHELL command
--     (hl.dsp.exec_cmd), so it runs it as a program.
--   * hl.dsp.exec_raw("hyprtasking:toggle") -- despite the name, exec_raw also shell-execs
--     (verified: it happily ran `touch`), so it is not a raw-dispatcher constructor.
-- Binding a Lua function works because command_from() passes non-table values through
-- untouched. "cursor" scopes the overview to the monitor under the pointer.
o.bind("SUPER + A", "Workspace overview", function()
  hl.plugin.hyprtasking.toggle("cursor")
end)
