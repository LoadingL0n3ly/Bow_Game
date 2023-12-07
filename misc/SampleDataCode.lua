local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local ProfileService = require(Modules.ProfileService)



local DataService = {
	DATA_VERSION = script:GetAttribute("Version"), -- `PlayerData_DEV_V0`,
	Profiles = {},
	BoundToRelease = {},
}

function DataService:GetProfile(player: Player)
	assert((typeof(player) == "Instance") and (player.ClassName == "Player"), `argument #1 must be a Player!`)
	
	local profile = self.Profiles[player]
	if profile then return profile end
	
	while true do
		if (not player) or (not player:IsDescendantOf(Players)) then return end
		
		profile = self.Profiles[player]
		
		if profile then break end
		
		self.ProfileLoaded:Wait()
	end
	
	return profile
end

function DataService:Release(player: Player)
	local profile = self:GetProfile(player)
	
	local boundToRelease = self.BoundToRelease[player]
	if boundToRelease and (#boundToRelease > 0) then
		for _, callback in boundToRelease do
			pcall(callback, profile)
		end
	end
	
	self.BoundToRelease[player] = nil
	
	profile:Release()	
end

function DataService:BindToRelease(player: Player, callback: (profile: any) -> any)
	if not (typeof(callback) == "function") then return end
	
	local boundToRelease = self.BoundToRelease[player]
	if not boundToRelease then
		self.BoundToRelease[player] = {}
	end
	
	table.insert(self.BoundToRelease[player], callback)
end

function DataService:KnitInit()
	local ProfileTemplate = require(script.ProfileTemplate)
	local ProfileStore = ProfileService.GetProfileStore(self.DATA_VERSION, ProfileTemplate)
	
	local function PlayerAdded(player: Player)
		local joinedAt = os.time()
		local userId = player.UserId

		local profile = ProfileStore:LoadProfileAsync(`player_{userId}`)

		if not profile then
			-- Profile could not be loaded

			player:Kick()

			return
		end


		profile:AddUserId(userId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			-- Profile potentially loaded on another server

			self.Profiles[player] = nil
			
			player:Kick()

			return
		end)

		if not player:IsDescendantOf(Players) then
			-- Player left before their profile loaded

			self:Release(player)

			return
		end

		self.Profiles[player] = profile
		
		self.Client.HasProfileLoaded:SetFor(player, true)
		self.ProfileLoaded:Fire(player)
		--Sessions[player] = sessionStart

		--OnProfileLoaded(player, profile)
	end
	
	local function PlayerRemoving(player: Player)
		local leftAt = os.time()
		--local sessionFinish = os.time()

		local profile = self.Profiles[player]
		if not profile then return end


		--local sessionStart = Sessions[player]
		--if sessionStart then
		--	table.insert(profile.Data.Sessions, { Start = sessionStart, Finish = sessionFinish, JobId = JobId })

		--	Sessions[player] = nil
		--end
		
		self:Release(player)
	end
	
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end
	
	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoving)
end

return DataService