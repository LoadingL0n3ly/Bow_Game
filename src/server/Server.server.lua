local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowHandler = require(Modules:WaitForChild("BowHandler"))


-- Connections
local function PlayerAdded(player: Player)
    BowHandler.PlayerAdded(player)
end

for _, player in pairs(Players:GetPlayers()) do
    PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    BowHandler.PlayerRemoving(player)
end)


-- Setup
task.spawn(BowHandler.Setup)
