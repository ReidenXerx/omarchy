# Local additions

Files this machine adds on top of Omarchy, kept here so a reinstall reproduces them.
Copy `config/hypr/*` to `~/.config/hypr/` and `bin/*` to `~/.local/bin/`.

## Workspace overview (`SUPER + A`)

Omarchy ships no Mission Control-style overview, and neither does Hyprland 0.56.

**`hyprexpo` no longer exists** — upstream removed it from `hyprland-plugins`, which now
ships only `borders-plus-plus`, `csgo-vulkan-fix`, `hyprbars` and `hyprfocus`. Its
maintained successor is [`hyprtasking`](https://github.com/raybbian/hyprtasking):

```bash
hyprpm add https://github.com/raybbian/hyprtasking
hyprpm enable hyprtasking
```

`SUPER + A` was chosen because it was genuinely unbound, so nothing was displaced:
`ALT+SHIFT+TAB` keeps reverse alt-tab and `SUPER+TAB` keeps "next workspace".

### How to call a plugin dispatcher (two dead ends first)

Hyprland 0.56 moved to a Lua config API, which changed how plugin dispatchers are reached.
Both of these **fail silently** — no error, the key just does nothing:

```lua
o.bind("SUPER + A", "...", "hyprtasking:toggle")                   -- runs it as a SHELL command
o.bind("SUPER + A", "...", hl.dsp.exec_raw("hyprtasking:toggle"))  -- also shell-execs, despite the name
```

`hl.dsp.exec_raw` was verified to shell-exec by handing it a `touch` command, which duly
created the file. `o.bind` treats any string dispatcher as `hl.dsp.exec_cmd`.

The working form is the plugin's own Lua namespace:

```lua
o.bind("SUPER + A", "Workspace overview", function()
  hl.plugin.hyprtasking.toggle("cursor")
end)
```

`hl.plugin.hyprtasking` also exposes `is_active`, `move`, `movewindow`, `setlayer`,
`killhovered` — and `is_active()` makes the binding testable without looking at the screen.

## `bin/hypr-plugin-check`

hyprpm plugins are compiled against one exact Hyprland build, so a `hyprland` upgrade leaves
them unloadable. Nothing announces it: the plugin's keys simply stop working, with no error
anywhere — miserable to diagnose months later. This runs at login and notifies if an enabled
plugin did not load, telling you to run `hyprpm update && hyprpm reload`.

**Why detection and not a pacman hook.** hyprpm's store is `/var/cache/hyprpm/$USER` and
root-owned. A root-run hook would use the wrong store; running it as the user mid-transaction
needs a password. Automating it would require a passwordless-sudo rule, which this machine
deliberately does not have (Omarchy's own installer adds one; it was skipped). Detection is
safe and free; the rebuild stays a deliberate action.

Parsing note: `hyprpm` colours output even when piped, and the escape sits *between* label
and value (`enabled: \e[32mtrue`), so a naive `grep 'enabled: true'` matches nothing and the
check passes while plugins are broken. ANSI is stripped before parsing.

## Also in `config/hypr/`

- **`autostart.lua`** — starts `hyprpolkitagent` (Omarchy starts no polkit agent, so
  authentication prompts fail silently) and runs the plugin check.
- **`looknfeel.lua`** — unchanged from stock; kept for completeness.
