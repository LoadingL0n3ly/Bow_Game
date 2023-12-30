local class = {}
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local Common = ReplicatedStorage:FindFirstChild("Common")
local BowClient = require(Common:FindFirstChild("BowClient"))
local MarketPlaceService = game:GetService("MarketplaceService")

-- Remotes
local ArrowShopRemotes = Remotes:WaitForChild("ArrowShop")
local EquipArrowEvent: RemoteFunction = ArrowShopRemotes:WaitForChild("EquipArrow")
local PurchaseArrowEvent: RemoteFunction = ArrowShopRemotes:WaitForChild("PurchaseArrow")

local GetProfile: RemoteFunction = Remotes:WaitForChild("GetProfile")

function class.AttemptArrowPurchase(ArrowName: string)
    -- Preventing any weird shenanigans
    if BowClient.Equipped then
        BowClient.Unequip()
    end

    -- Preliminary Checks
    local profile = GetProfile:InvokeServer()
    if not profile then return end
    if profile.Data.Inventory.Arrows[ArrowName] then warn("Player already owns Arrow, you're doing something wrong!") return end

    -- Making sure the arrow exists
    local ArrowData = require(ReplicatedStorage.Database.ArrowData)[ArrowName]
    if not ArrowData then warn("ArrowData not found for " .. ArrowName) return end

    -- Making sure it's not a gamepass arrow
    if profile.Data.Purchase.Gamepass then
        print("Player is purchasing a gamepass arrow!")
        MarketPlaceService:PromptGamePassPurchase(Player, ArrowData.Purchase.Gamepass)
        return
    end

    -- Making sure the player has enough money
    if profile.Data.Currency.Gold < ArrowData.Purchase.Price then
        warn("Player doesn't have enough money to purchase arrow!")
        return
    end

    -- Attempting to purchase arrow
    local Response = PurchaseArrowEvent:InvokeServer(ArrowName)
    if not Response then
        warn("Server didn't accept purchase request!")
        return
    end

    return true
end

function class.AttemptArrowEquip(ArrowName: string)
    -- Preventing any weird shenanigans
    if BowClient.Equipped then
        BowClient.Unequip()
    end

    -- Preliminary Checks
    local profile = GetProfile:InvokeServer()
    if not profile then return end
    if profile.Data.ActiveArrow == ArrowName then warn("Player already equipped Arrow!") return end
    if not profile.Data.Inventory.Arrows[ArrowName] then warn("Player doesn't own Arrow!") return end

    -- Making sure the arrow exists
    local ArrowData = require(ReplicatedStorage.Database.ArrowData)[ArrowName]
    if not ArrowData then warn("ArrowData not found for " .. ArrowName) return end

    -- Attempting to equip arrow
    local Response = EquipArrowEvent:InvokeServer(ArrowName)
    if not Response then
        warn("Server didn't accept equip request!")
        return
    end

    return true
end


return class