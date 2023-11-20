local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowHandler = require(Common:WaitForChild("BowHandler"))
local BannerNotif = require(Common.BannerNotif)

local welcomeConfig = {
	.3, 							-- Background Transparency
	Color3.new(0.549019, 0.933333, 0.470588), 		-- Background Color
	
	0, 								-- Content Transparency
	Color3.new(255, 255, 255), 	-- Content Color
}

-- Connections
local function PlayerAdded(player: Player)
    BowHandler.PlayerAdded(player)
    BannerNotif:Notify("Welcome!", `Bow Battles Dev Place Version {workspace:GetAttribute("Version")}`, "rbxassetid://15375550133", 5, welcomeConfig, player)

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