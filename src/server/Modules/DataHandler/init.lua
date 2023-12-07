local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Utils = ServerScriptService.Utils
local ProfileService = require(Utils.ProfileService)
local GetProfileEvent: RemoteFunction = Remotes.GetProfile -- Client Fetch Event

local ProfileLoaded = Instance.new("BindableEvent")
ProfileLoaded.Name = "ProfileLoaded"
ProfileLoaded.Parent = script

local DataService = {
    DATA_VERSION = workspace:GetAttribute("Version"), -- `PlayerData_DEV_V0`,
    Profiles = {},
    BoundToRelease = {},

    ProfileLoaded = ProfileLoaded,
}

function DataService:GetProfile(player: Player)
    assert((typeof(player) == "Instance") and (player.ClassName == "Player"), `argument #1 must be a Player!`)

    local profile = self.Profiles[player]
    if profile then return profile end

    -- checks if player exists (returning nil if not), and if profile doesn't exist it waits untill profile loaded is fired
    while true do
		if (not player) or (not player:IsDescendantOf(Players)) then return end
		
        profile = self.Profiles[player]
		if profile then break end
		
		self.ProfileLoaded.Event:Wait()
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

function DataService:Init()
    local ProfileTemplate = require(script.ProfileTemplate)
    local ProfileStore = ProfileService.GetProfileStore(self.DATA_VERSION, ProfileTemplate)

    local function PlayerAdded(player: Player)
        local id = player.UserId
        local profile = ProfileStore:LoadProfileAsync(`player_{id}`)

        if not profile then
            player:Kick(`Unable to load profile player_{id}, contact Developers if this persists after rejoin.`)
            return
        end

        profile:AddUserId(id) -- gdpr compliance
        profile:Reconcile() -- fills in the blanks from template
        
        profile:ListenToRelease(function()
            self.Profiles[player] = nil
            player:Kick(`Profile player_{id} was released (was it loaded in another server?), contact Developers if this persists after rejoin.`)
            return
        end)

        -- if player leaves really quickly before loading completes
        if not player:IsDescendantOf(Players) then
            self:Release()
            return
        end

        self.Profiles[player] = profile
        self.ProfileLoaded:Fire(player)
    end

    local function PlayerRemoving(player: Player)
        local profile = self.Profiles[player]
        if not profile then return end
        self:Release(player)
    end

    -- in the case player joins before setup is run
    for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

    Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoving)

    GetProfileEvent.OnServerInvoke = function(player: Player)
        return self:GetProfile(player).Data
    end
end

return DataService