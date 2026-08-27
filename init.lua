-- Experiment 17 | Private MM2 semantic modular v7
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
