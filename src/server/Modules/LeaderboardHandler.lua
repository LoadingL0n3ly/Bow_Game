local Players = game.Players
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local ChatHandler = require(Modules:WaitForChild("ChatHandler"))
local DataHandler = require(Modules:WaitForChild("DataHandler"))

local class = {}

DataHandler.ProfileLoaded.Event:Connect(function(player: Player)
    local profile = DataHandler:GetProfile(player)

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local KillCount: IntValue = Instance.new("IntValue")
    KillCount.Name = "Kills"
    KillCount.Value = profile.Data.Stats.Kills
    KillCount.Parent = leaderstats
end)


local function Killed(attacker: Player, victim: Player)
    local profile = DataHandler:GetProfile(attacker)
    profile.Data.Stats.Kills += 1

    local leaderstats = attacker:FindFirstChild("leaderstats")
    if leaderstats then
        local KillCount = leaderstats:FindFirstChild("Kills")
        if KillCount then
            KillCount.Value = profile.Data.Stats.Kills
        end
    end
end

function class.DamageDoneToPlayer(attacker: Player, victim: Player, damage: number, killed: boolean,weapon: string)
    local msg = attacker.Name .. " dealt " .. damage .. " damage to " .. victim.Name .. " with a " .. weapon
    ChatHandler.sendMessage(msg, "#ff0000")

    task.delay(0.1, function()
        if killed then
            Killed(attacker, victim)
            ChatHandler.sendMessage(victim.Name .. " was killed by " .. attacker.Name, Color3.new(0.764705, 0, 1):ToHex())
        end
    end)
end


return class