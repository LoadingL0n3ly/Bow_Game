local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowHandler = require(Common:WaitForChild("BowHandler"))
local BannerNotif = require(Common.BannerNotif)

-- Connections
local function PlayerAdded(player: Player)
    BowHandler.PlayerAdded(player)
    BannerNotif:Notify("Welcome!", `Bow Battles Dev Place Version {workspace:GetAttribute("Version")}. Use E to Equip and Q to Toggle Ability`, "rbxassetid://15375550133", 5, nil, player)

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

print("awesome tax!")