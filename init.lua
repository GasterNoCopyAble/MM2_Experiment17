-- Experiment 17 | Private MM2 modular v7
-- Each module is compiled separately to avoid Luau's 200-local-register limit.

local BASE = "https://raw.githubusercontent.com/GasterNoCopyAble/MM2_Experiment17/main/"
local MODULES = {
    "src/modules/01.lua",
    "src/modules/02.lua",
    "src/modules/03.lua",
    "src/modules/04.lua",
    "src/modules/05.lua",
    "src/modules/06.lua",
    "src/modules/07.lua",
    "src/modules/08.lua",
    "src/modules/09.lua",
    "src/modules/10.lua",
    "src/modules/11.lua",
    "src/modules/12.lua",
    "src/modules/13.lua",
    "src/modules/14.lua",
    "src/modules/15.lua",
    "src/modules/16.lua",
}

local compiler = loadstring or (getgenv and getgenv().loadstring)
if type(compiler) ~= "function" then
    error("[MM2 Experiment17] loadstring unavailable")
end

local rootEnv = (getgenv and getgenv()) or _G
local canSetEnv = type(setfenv) == "function"
local runtimeEnv

if canSetEnv then
    runtimeEnv = {}
    setmetatable(runtimeEnv, {__index = rootEnv})
    runtimeEnv._G = runtimeEnv
    runtimeEnv.getgenv = function() return runtimeEnv end
else
    -- Executors without setfenv still share their normal global environment.
    runtimeEnv = rootEnv
end

rootEnv.__E17_MM2_MODULAR_ENV = runtimeEnv

local function loadModule(path)
    local okHttp, source = pcall(function()
        return game:HttpGet(BASE .. path)
    end)

    if not okHttp or type(source) ~= "string" or #source == 0 then
        error("[MM2 Experiment17] HTTP FAILED: " .. path .. " | " .. tostring(source))
    end

    local chunk, compileError = compiler(source, "@" .. path)
    if not chunk then
        error("[MM2 Experiment17] COMPILE FAILED: " .. path .. " | " .. tostring(compileError))
    end

    if canSetEnv then
        setfenv(chunk, runtimeEnv)
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        error("[MM2 Experiment17] RUNTIME FAILED: " .. path .. " | " .. tostring(result))
    end

    return result
end

for _, path in ipairs(MODULES) do
    loadModule(path)
end

return runtimeEnv.Library
