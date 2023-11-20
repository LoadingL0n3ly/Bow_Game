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

local ArrowModules = Arrow.ArrowModules

function class.GetArrowModule(player: Player)
    local bowName = class.GetBowName(player)

    local module = require(ArrowModules[bowName])
    if not module then
        error("No module found for bow: " .. bowName)
        return
    end

    return module, bowName
end

return class