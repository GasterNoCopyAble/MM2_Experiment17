# MM2 Experiment17

Experiment 17 private MM2 script, organized by feature systems instead of arbitrary chunks.

## Loader

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/GasterNoCopyAble/MM2_Experiment17/main/init.lua"
))()
```

## Modules

- `src/Core.lua` — shared state, roles, services, helpers and Experiment17 sections
- `src/Combat.lua` — Kill All, Shoot Murderer, Silent Shot
- `src/HUD.lua` — overlay/HUD runtime and performance sampling
- `src/ESP.lua` — player ESP, Skeleton, Offscreen Arrows, Chams, trails, heatmap/death visuals
- `src/World.lua` — object cache, Dropped Gun, Coins, Murderer threat system, Role Arrow, XRay
- `src/Player.lua` — movement, Fly, Noclip, Click TP, Ghost
- `src/Camera.lua` — Spectate and Freecam
- `src/Fling.lua` — Anti Fling, Touch Fling, Target Fling and Fling All
- `src/Target.lua` — target system, player TP, return position and bookmarks
- `src/UI.lua` — Experiment17 controls, dropdowns, keybinds and favorites
- `src/Lifecycle.lua` — respawn restore, cleanup and unload

The semantic modules are loaded as separate Luau chunks, so the old `200 local registers` problem is avoided without turning the repository into numbered fragments.
