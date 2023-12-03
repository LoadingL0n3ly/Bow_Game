local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local Common = ReplicatedStorage.Common
local Arrow = require(Common.Arrow)

local Players = game.Players



function class.GetBowName(player: Player)
    return "Test"
end

function class.GetArrowName(player: Player)
    return "Test"
end

local ArrowModules = Arrow.ArrowModules

function class.GetArrowModule(player: Player)
    local arrowName = class.GetArrowName(player)

    local module = require(ArrowModules[arrowName])
    if not module then
        error("No module found for bow: " .. arrowName)
        return
    end

    return module, arrowName
end

return class