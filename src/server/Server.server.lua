local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ServerScriptService:WaitForChild("Modules")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowHandler = require(Modules:WaitForChild("BowHandler"))

-- Setup
BowHandler.Setup()
