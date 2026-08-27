from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
NUM = ROOT / 'src' / 'modules'
SRC = ROOT / 'src'

if not (NUM / '01.lua').exists():
    print('Semantic layout already present; nothing to do.')
    raise SystemExit(0)

parts = []
for i in range(1, 17):
    path = NUM / f'{i:02}.lua'
    text = path.read_text(encoding='utf-8')
    lines = text.splitlines()
    if lines and lines[0].startswith('-- Experiment17 MM2 modular v7 | module'):
        lines = lines[1:]
    parts.append('\n'.join(lines).strip())

source = '\n'.join(parts) + '\n'

markers = [
    ('Core.lua', None, 'Core'),
    ('Combat.lua', 'function BringPlayerExact(player, targetCF)', 'Combat'),
    ('HUD.lua', 'Overlay = Instance.new("Frame")', 'HUD / visual runtime'),
    ('ESP.lua', 'ESPObjects = {}', 'ESP'),
    ('World.lua', 'function GetAdornmentPart(object)', 'World'),
    ('Player.lua', 'OriginalWalkSpeed = 16', 'Player / movement'),
    ('Camera.lua', 'SpectateChoice\nSpectateToggle', 'Camera'),
    ('Fling.lua', 'AntiFlingCollisionCache = setmetatable({}, {__mode = "k"})', 'Fling / protection'),
    ('Target.lua', 'TargetMainChoice\nBookmarkChoice', 'Target / teleport / bookmarks'),
    ('UI.lua', 'Controls.KillAll = MurderSection:AddToggle({', 'UI / keybinds / favorites'),
    ('Lifecycle.lua', 'Connect(LP.CharacterAdded, function(character)', 'Lifecycle / cleanup'),
]

positions = []
for filename, marker, title in markers:
    pos = 0 if marker is None else source.find(marker)
    if pos < 0:
        raise RuntimeError(f'Marker for {filename} was not found: {marker!r}')
    positions.append((filename, pos, title))

for index, (filename, start, title) in enumerate(positions):
    end = positions[index + 1][1] if index + 1 < len(positions) else len(source)
    body = source[start:end].strip() + '\n'
    header = (
        f'-- Experiment 17 | Private MM2 modular v7 | {title}\n'
        '-- Semantic feature module. Loaded by init.lua into one shared runtime environment.\n\n'
    )
    (SRC / filename).write_text(header + body, encoding='utf-8')

init = '''-- Experiment 17 | Private MM2 semantic modular v7
-- Each module owns one complete feature system.

local BASE = "https://raw.githubusercontent.com/GasterNoCopyAble/MM2_Experiment17/main/src/"
local MODULES = {
    "Core.lua",
    "Combat.lua",
    "HUD.lua",
    "ESP.lua",
    "World.lua",
    "Player.lua",
    "Camera.lua",
    "Fling.lua",
    "Target.lua",
    "UI.lua",
    "Lifecycle.lua",
}

local compiler = loadstring or (getgenv and getgenv().loadstring)
if type(compiler) ~= "function" then
    error("[MM2 Experiment17] loadstring is unavailable")
end

local rootEnv = (getgenv and getgenv()) or _G
local previous = rootEnv.__E17_MM2_MODULAR_ENV
if previous and previous.Library and type(previous.Library.Unload) == "function" then
    pcall(function() previous.Library:Unload() end)
end

local runtimeEnv = {}
setmetatable(runtimeEnv, {__index = rootEnv})
runtimeEnv._G = runtimeEnv
runtimeEnv.getgenv = function() return runtimeEnv end
rootEnv.__E17_MM2_MODULAR_ENV = runtimeEnv

local function loadModule(name)
    local okHttp, source = pcall(function()
        return game:HttpGet(BASE .. name)
    end)
    if not okHttp or type(source) ~= "string" or #source == 0 then
        error("[MM2 Experiment17] HTTP FAILED: " .. name .. " | " .. tostring(source))
    end

    local chunk, compileError = compiler(source, "@src/" .. name)
    if not chunk then
        error("[MM2 Experiment17] COMPILE FAILED: " .. name .. " | " .. tostring(compileError))
    end

    if type(setfenv) == "function" then
        setfenv(chunk, runtimeEnv)
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        error("[MM2 Experiment17] RUNTIME FAILED: " .. name .. " | " .. tostring(result))
    end
    return result
end

for _, name in ipairs(MODULES) do
    loadModule(name)
end

return runtimeEnv.Library
'''
(ROOT / 'init.lua').write_text(init, encoding='utf-8')

readme = '''# MM2 Experiment17

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
'''
(ROOT / 'README.md').write_text(readme, encoding='utf-8')

shutil.rmtree(NUM)

for extra in [ROOT / 'tools' / 'restructure.py', ROOT / '.github' / 'workflows' / 'restructure.yml']:
    if extra.exists():
        extra.unlink()

for directory in [ROOT / 'tools', ROOT / '.github' / 'workflows', ROOT / '.github']:
    try:
        directory.rmdir()
    except OSError:
        pass

print('Semantic modules generated successfully.')
for path in sorted(SRC.glob('*.lua')):
    print(path.relative_to(ROOT), path.stat().st_size)
