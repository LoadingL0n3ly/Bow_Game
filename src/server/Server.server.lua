local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local DataHandler = require(Modules:WaitForChild("DataHandler"))
local BowHandler = require(Common:WaitForChild("BowHandler"))
local BannerNotif = require(Common.BannerNotif)
local ChatHandler = require(Modules:WaitForChild("ChatHandler"))
local LeaderboardHandler = require(Modules:WaitForChild("LeaderboardHandler"))

-- Player Connection Tables
local PlayerConnections = {}

-- Print Debug
function _G.dprint(text: string)
    if not workspace:GetAttribute("Debug") then return end
    print(text)
end

-- Data Setup
DataHandler:Init()

-- Connections
local function PlayerAdded(player: Player)
    ChatHandler.playerJoined(player.Name)
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
    ChatHandler.playerLeft(player.Name)
    BowHandler.PlayerRemoving(player)

    for index, connection in pairs(PlayerConnections[player]) do
        PlayerConnections[player][index] = nil
        connection:Disconnect()
    end
end)

-- For NPC Hitboxes
for _, npc in workspace.Dummies:GetChildren() do
    BowHandler.CharacterAdded(npc)
end

-- Setup
task.spawn(BowHandler.Setup)

