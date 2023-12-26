local class = {}

-- Core
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ServerScriptService.Modules
local Common = ReplicatedStorage.Common
local Remotes = ReplicatedStorage.Remotes
local Database = ReplicatedStorage.Database

-- Modules
local DataHandler = require(Modules.DataHandler)
local ArrowData = require(Database.ArrowData)


function class.EquipArrow(player: Player, arrowName: string)
    local profile = DataHandler:GetProfile(player)
    if not profile then return end

    if not profile.Data.Inventory.Arrows[arrowName] then 
        warn(`{player.Name} doesn't owned {arrowName}`)
        return 
    end

    profile.Data.ActiveArrow = arrowName
end


-- Player purchasing/getting arrow
function class.AddArrow(player: Player, arrowName: string)
    local profile = DataHandler:GetProfile(player)
    if not profile then return end

    print(`{player.Name} acquired arrow {arrowName}`)
    profile.Data.Inventory.Arrows[arrowName] = {
        Level = 1,
    }
end

function class.PurchaseArrow(player: Player, arrowName: string)
    local profile = DataHandler:GetProfile(player)
    if not profile then return end

    if profile.Data.Inventory.Arrows[arrowName] then
        warn("Player already owns arrow: " .. arrowName)
        return
    end

    local R_Data = ArrowData[arrowName]
    if not R_Data then warn(`No bow data found for {arrowName}`) return end
    if R_Data.Purchase.Gamepass then warn(`{arrowName} is a gamepass purchase, something is going wrong`) return end


    profile.Data.Currency.Gold -= R_Data.Purchase.Price
    print(`{player.Name} purchased {arrowName} for {R_Data.Purchase.Price} gold`)
    class.AddArrow(player, arrowName)
end






return class