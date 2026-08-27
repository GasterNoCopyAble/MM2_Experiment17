# MM2 Experiment17

Modular build of Experiment 17 Private MM2 v7.

The previous monolithic build could hit Luau's compiler limit with `Out of local registers ... exceeded limit 200`. The loader now downloads and compiles the script as 16 separate chunks while keeping one shared runtime state.

## Load

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/GasterNoCopyAble/MM2_Experiment17/main/init.lua"
))()
```

## Layout

```text
MM2_Experiment17/
├─ init.lua
└─ src/
   └─ modules/
      ├─ 01.lua
      ├─ 02.lua
      ├─ ...
      └─ 16.lua
```

`init.lua` loads the chunks in order and reports the exact module path on HTTP, compile, or runtime failure, making syntax/runtime problems much easier to locate.

The GUI is still loaded from `GasterNoCopyAble/Experiment17_GuiLib` Legacy v22.
