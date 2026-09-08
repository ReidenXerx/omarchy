# Omarchy

Omarchy is a beautiful, fun & agentic Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## The Omarchy Manual

The manual lives in [`manual/`](manual/), which is its authoritative source. It's
mirrored to [learn.omacom.io](https://learn.omacom.io/2/the-omarchy-manual), where
its screenshots are also hosted.

- [Welcome to Omarchy!](manual/01-welcome-to-omarchy.md)

**The Basics**

- [Getting Started](manual/02-getting-started.md)
- [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md)
- [Navigation](manual/04-navigation.md)
- [The top bar](manual/05-the-top-bar.md)
- [Themes](manual/06-themes.md)
- [Hotkeys](manual/07-hotkeys.md)
- [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
- [Reminders](manual/09-reminders.md)
- [Notices](manual/10-notices.md)
- [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
- [Screenshots & Recording](manual/12-screenshots-recording.md)
- [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
- [Omarchy CLI](manual/14-omarchy-cli.md)

**The Applications**

- [Terminal](manual/15-terminal.md)
- [Neovim](manual/16-neovim.md)
- [AI](manual/17-ai.md)
- [Development Tools](manual/18-development-tools.md)
- [Shell Tools](manual/19-shell-tools.md)
- [Shell Functions](manual/20-shell-functions.md)
- [TUIs](manual/21-tuis.md)
- [GUIs](manual/22-guis.md)
- [Browsers](manual/23-browsers.md)
- [Commercial apps/services](manual/24-commercial-apps-services.md)
- [Web Apps](manual/25-web-apps.md)
- [Gaming](manual/26-gaming.md)
- [Filling out PDFs](manual/27-filling-out-pdfs.md)
- [Windows VM](manual/28-windows-vm.md)
- [Other Packages](manual/29-other-packages.md)

**Configuration**

- [Updates](manual/30-updates.md)
- [Dotfiles](manual/31-dotfiles.md)
- [Shell plugins](manual/32-shell-plugins.md)
- [Monitors](manual/33-monitors.md)
- [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md)
- [Networking](manual/35-networking.md)
- [System sleep](manual/36-system-sleep.md)
- [Hardware authentication](manual/37-hardware-authentication.md)
- [Fonts](manual/38-fonts.md)
- [Backgrounds](manual/39-backgrounds.md)
- [Prompt](manual/40-prompt.md)
- [Branding](manual/41-branding.md)
- [Common tweaks](manual/42-common-tweaks.md)
- [Making your own theme](manual/43-making-your-own-theme.md)

**The Rest**

- [Mac support](manual/44-mac-support.md)
- [Troubleshooting](manual/45-troubleshooting.md)
- [FAQ](manual/46-faq.md)
- [System snapshots](manual/47-system-snapshots.md)
- [Security](manual/48-security.md)
- [Omarchy on...](manual/49-omarchy-on.md)
- [Dual Boot Install](manual/50-dual-boot-install.md)
- [Unattended Installs](manual/51-unattended-installs.md)

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## This fork: side-by-side install notes

This fork runs Omarchy **alongside an existing EndeavourOS + KDE Plasma install** on an
Alienware x16 R2, rather than as the machine's only OS. Omarchy's installer assumes it owns
the system, so it was not run. The desktop was assembled by hand instead, and this section
records every deviation and why — so the differences are recoverable rather than folklore.

### Layout

`OMARCHY_PATH` points at `~/.local/share/omarchy` (this checkout) instead of
`/usr/share/omarchy`, so no root-owned copy exists and the whole desktop is user-local.
The session entry is a five-line `.desktop` in `/usr/share/wayland-sessions/`, which is the
only file installed outside `$HOME`.

**Consequence:** anything hardcoding `/usr/share/omarchy` or `/usr/bin/omarchy-*` is inert
or broken here. `omarchy-sleep-lock.service` needed its `ExecStart` repointed at this
checkout; `omarchy-migrate-notify.service` stays inert because it is conditioned on
`/usr/share/omarchy/migrations`.

### Installer scripts deliberately not run

Packages are system-wide, but **installing a package is not the same as enabling it** —
Arch enables nothing on install. Everything genuinely invasive in Omarchy lives in these
scripts, not in the package list, so skipping them is what keeps the host system intact:

| path | what it would do |
|---|---|
| `install/post-install/pacman.sh` | replaces `/etc/pacman.conf` and the mirrorlist wholesale |
| `install/config/enable-services.sh` | enables `sddm`, `cups`, `docker.socket`, `avahi`, oomd |
| `install/config/firewall.sh` | sets `ENABLED=yes` in ufw with `default deny incoming` |
| `etc/tmpfiles.d/omarchy-nopasswd-sudo.conf` | grants passwordless sudo |
| `etc/tmpfiles.d/omarchy-zswap.conf` | enables zswap — already disabled here, deliberately |
| `etc/systemd/logind.conf.d/` | overrides power-button and inhibit-delay behaviour |
| `install/login/sddm.sh` | installs a second display manager; `plasmalogin` owns that role |

The **user-level** scripts (`install/user/**`) are the safe subset: they run as the user and
write only into `$HOME`. Two still needed care — `user/xcompose.sh` overwrites `~/.XCompose`
outright and hardcodes `/usr/share/omarchy`, and `user/first-run/enable-user-units.sh`
assumes the units are in `/usr/lib/systemd/user`, where a package would have put them.

### Packages skipped from `omarchy-base.packages`

Of the 150, six are not installed:

- **`sddm`** — installing it is harmless, but `plasmalogin` already owns
  `display-manager.service`; a second display manager only invites confusion later.
- **`ufw`**, **`ufw-docker`** — skipped as unwanted here, not as unsafe; both are inert
  until enabled. Worth knowing if ufw is ever turned on: Omarchy's ruleset is
  `default deny incoming`, which would block inbound Tailscale and SSH to this host.
- **`docker-buildx`**, **`docker-compose`** — skipped for the same reason. `docker` itself
  was already installed on this machine, and its service is left `disabled`.
- **`ttf-jetbrains-mono-nerd-basic`** — conflicts with the full `ttf-jetbrains-mono-nerd`
  already installed. Theirs is a subset of the same 3.5.1 release, so the full one was kept.

`nvim` in their list is satisfied by Arch's `neovim`, which provides the same binary.

Trimming further was a mistake worth recording: an initial 17-package install left
`yaru-icon-theme` missing while gsettings still pointed at `Yaru-blue` (every icon rendered
as the missing-icon placeholder), `ttf-ia-writer` missing so text silently fell back to Noto
Sans at different metrics, and no `xdg-terminal-exec`, which surfaced as a desktop
notification reading `Command not found: "xdg-terminal-exec"`.

### Additions upstream does not ship

- **`otf-font-awesome`** — upstream ships only `woff2-font-awesome`, which contains no
  `.ttf`/`.otf` files, so fontconfig cannot serve it to native applications.
- **`hyprpolkitagent`**, started from `~/.config/hypr/autostart.lua` — Omarchy's autostart
  launches no polkit agent, so only `polkitd` runs and anything needing authentication
  fails silently instead of prompting. Started per-session rather than
  `systemctl --user enable`d, because the unit is `WantedBy=graphical-session.target` and
  enabling it would also start it under Plasma, which runs its own agent.

### Upstream fix carried here

Branch `fix/hybrid-gpu-no-glx-pin` stops `default/hypr/nvidia.lua` pinning
`__GLX_VENDOR_LIBRARY_NAME=nvidia` on hybrid laptops, and rewrites
`omarchy-hw-hybrid-gpu` to count GPUs from sysfs instead of `lspci` — which resumes a
runtime-suspended GPU, the very thing the sibling NVIDIA detectors avoid and document.
Applicable to any Optimus machine, not just this one.
