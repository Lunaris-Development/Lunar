# Lunar

A modular Roblox admin/utility hub. A tiny loader pulls a shared **core framework** (services, cleanup Maids, config persistence, a command registry) and a set of feature modules, then builds a UI from whatever registered.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunaris-Development/Lunar/main/loader.lua"))()
```

- Open / close the menu with **Right Shift**, the floating Lunar button, or by typing `cmds`.
- Run commands from the in-menu console, or just type them in chat.
- Commands accept an optional prefix (`l?`, `;`, `.`, `/`, `!`) — e.g. `fly` or `;fly`.

## Architecture

```
loader.lua            bootstraps everything, fetches modules with error isolation
src/core.lua          framework: services, Maid, Signal, Config, command registry, helpers
src/ui.lua            notifications, draggable command window, console, server panel
src/modules/
  movement.lua        fly, noclip, walkair, infjump, speed, loopspeed, jumppower
  player.lua          god, invis, freecam, flip, backflip
  combat.lua          aimlock, reach, fling, touchfling
  teleport.lua        tp, clicktp
  visuals.lua         esp (+ box/hp/names/skeleton/highlight), fullbright
  server.lua          antiafk, lagspoof, spoof, serverinfo, serverlist, serverhop, rejoin, shlow, shmost
  fun.lua             rizz, say, unload
```

Each module registers commands with `Core.Commands:Register{...}` and cleans itself up through a `Core.Maid()`, so toggling a feature **off** disconnects every event and destroys every instance it made. Modules never touch each other directly — the UI and chat both go through the one command registry.

## Commands

Type `cmds` (or press Right Shift) to see the full, searchable list with live toggle state.
