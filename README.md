# Lunar

A Roblox admin/utility hub with a macOS-style dynamic island UI, gated by server-side access control.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunaris-Development/Lunar/main/loader.lua"))()
```

- `loader.lua` checks your access against the Lunar backend before loading anything. No access = no load.
- Open the menu with the top-right bar's command icon, or type `cmds` in chat.
- Press **F2** for the console. Press **E** to toggle fly.
- Commands accept an optional `l?` prefix in chat (e.g. `fly` or `l?fly`).

## Architecture

```
loader.lua        auth gate (via net.lua) + loads every module below
net.lua           HTTP client to the Lunar backend (auth, config, nametags, roster)
UI.lua            the dynamic island: bar, draggable windows, F2 console, notifications
Nametags.lua      role nametags above other Lunar users — server-driven, not client-replicated
AimLock.lua, AntiAFK.lua, ClickTP.lua, ESP.lua, Flip.lua, Freecam.lua,
GlobalChat.lua, GodMode.lua, Hug.lua, InfJump.lua, Invisible.lua,
LagSpoof.lua, LoopSpeed.lua, NametageGUI.lua, Noclip.lua, PlayerTP.lua,
ProperFling.lua, Reach.lua, Rizzlines.lua, ServerInfo.lua, ServerList.lua,
ShLow.lua, ShMost.lua, TouchFling.lua, UserSpoofer.lua, WalkOnAir.lua
                  individual feature modules — each exposes HandleChat(msg, UI[, ESP][, silent])
```

Every module is loaded fresh from GitHub on each run and dispatched through a single `Commands.HandleChat` in `loader.lua`. The UI calls into modules the same way chat does — there's one dispatch path.

## Backend

Access, per-user config, and nametag roles are served by `lunar-api` (its own process, its own database) via `net.lua`. Grant access to a user by Roblox username or ID from the admin panel — access checks by username before someone has ever run the script, then binds to their Roblox ID the first time they load in.
