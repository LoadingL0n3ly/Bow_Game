local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local DataHandler = require(Modules.DataHandler)
local Common = ReplicatedStorage.Common
local Arrow = require(Common.Arrow)

local Players = game.Players

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Database = ReplicatedStorage.Database

local ArrowData = require(Database.ArrowData)



function class.GetBowName(player: Player)
    local profile = DataHandler:GetProfile(player)
    if not profile then return end

    assert(profile.Data.EquippedBow, "No bow equipped!")
    return profile.Data.EquippedBow
end

function class.GetArrowName(player: Player)
    local profile = DataHandler:GetProfile(player)
    if not profile then return end

    assert(profile.Data.EquippedArrow, "No arrow equipped!")
    return profile.Data.EquippedArrow
end

local ArrowModules = Arrow.ArrowModules

function class.GetArrowModule(player: Player)
    local arrowName = class.GetArrowName(player)
    local Data = ArrowData[arrowName] assert(Data, "No data found for arrow: " .. arrowName)

    local module = require(Data.Module)
    if not module then
        error("No module found for bow: " .. arrowName)
        return
    end

    return module, arrowName
end

return class