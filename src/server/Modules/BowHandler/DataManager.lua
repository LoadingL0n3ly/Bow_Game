local class = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local Arrow = Modules.Arrow

local Players = game.Players



function class.GetBowName(player: Player)
    return "Test"
end

local ArrowModules = {
    ["Test"] = require(Arrow.TestArrow),
}

function class.GetArrowModule(player: Player)
    local bowName = class.GetBowName(player)

    local module = ArrowModules[bowName]
    if not module then
        error("No module found for bow: " .. bowName)
        return
    end

    return module
end

return class