local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowHandler = require(Common:WaitForChild("BowHandler"))
local BannerNotif = require(Common.BannerNotif)

-- Player Connection Tables
local PlayerConnections = {}

-- Connections
local function PlayerAdded(player: Player)
    PlayerConnections[player] = {}
    
    BowHandler.PlayerAdded(player)
    BannerNotif:Notify("Welcome!", `Bow Battles Dev Place Version {workspace:GetAttribute("Version")}. Use E to Equip and Q to Toggle Ability`, "rbxassetid://15375550133", 5, nil, player)
    PlayerConnections[player]["CharacterAdded"] = player.CharacterAdded:Connect(function(character)
        BowHandler.CharacterAdded(character)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    BowHandler.PlayerRemoving(player)

    for index, connection in pairs(PlayerConnections[player]) do
        PlayerConnections[player][index] = nil
        connection:Disconnect()
    end
end)



-- Setup
task.spawn(BowHandler.Setup)