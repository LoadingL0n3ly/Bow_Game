local class = {}

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local Database = ReplicatedStorage:WaitForChild("Database")
local Utils = ReplicatedStorage:WaitForChild("Utils")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Replication = require(script.Replication)

local BowRemotes = Remotes:WaitForChild("BowRemotes")
local EquipBowEvent: RemoteFunction = BowRemotes:WaitForChild("EquipBow")
local UnequipBowEvent: RemoteFunction = BowRemotes:WaitForChild("UnequipBow")

-- Modules
local Shiftlock = require(script:WaitForChild("Shiftlock"))
local FiringClient = require(script:WaitForChild("FiringClient"))

-- CONSTANTS 
local EQUIP_KEY = Enum.KeyCode.E

-- CORE VARIABLES 
local Equipped = false
local Can_Equip = true -- make this depend on game condition

-- Functions
function class.Equip()
    local ServerResponse = EquipBowEvent:InvokeServer()
    assert(ServerResponse, "Server did not accept Equip Request!")
    if not ServerResponse then return end

    local Character = Player.Character
    if not Character then print("Shiftlock couldn't fix character!") return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end

    Shiftlock.ShiftLock(true)
    FiringClient.Equip()
    Equipped = true
end

function class.Unequip()
    local ServerResponse = UnequipBowEvent:InvokeServer()
    assert(ServerResponse, "Server did not accept UnEquip Request!")
    if not ServerResponse then return end

    Shiftlock.ShiftLock(false)
    FiringClient.Unequip()
    Equipped = false
end

-- Setup Code
function class.Setup()
    UserInputService.InputBegan:Connect(function(Input: InputObject, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode ~= EQUIP_KEY then return end

        if Equipped then
            class.Unequip()     
        elseif Can_Equip then
            class.Equip()
        end
    end)

    Replication.Setup()
end


return class