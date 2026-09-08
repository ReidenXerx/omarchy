-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Polkit authentication agent.
--
-- Omarchy's defaults start no polkit agent, so only polkitd (the daemon) runs and any
-- action needing authentication has nothing to draw a prompt with: it fails silently
-- rather than asking. hyprpolkitagent supplies that UI.
--
-- Started here rather than `systemctl --user enable`d, because its unit is
-- WantedBy=graphical-session.target -- enabling it would also start it under Plasma,
-- which runs its own polkit-kde agent, and only one agent can register per session.
-- Starting it from Hyprland's autostart keeps it scoped to this session.
--
-- exec_on_start, not launch_on_start: the latter wraps the command in `uwsm-app --`,
-- which is for launching applications, not for asking systemd to start a unit.
o.exec_on_start("systemctl --user start hyprpolkitagent.service")

-- Warn if an hyprpm plugin is enabled but failed to load (see ~/.local/bin/hypr-plugin-check).
-- Plugins are built against one exact Hyprland build, so an upgrade silently unloads them
-- and their keybindings just stop working with no error. Delayed so the compositor and the
-- notification daemon are both up before it asks them anything.
o.exec_on_start("sleep 8 && " .. os.getenv("HOME") .. "/.local/bin/hypr-plugin-check")
