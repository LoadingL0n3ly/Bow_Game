local class = {}

local Players = game.Players
local ReplicatedStorage = game.ReplicatedStorage
local Remotes = ReplicatedStorage.Remotes

local BowRemotes = Remotes.BowRemotes

local UpdateAbilityArrowCountEvent: RemoteEvent = BowRemotes.UpdateAbilityArrowCount
local ToggleArrow: RemoteFunction = BowRemotes.ToggleArrow
local CanFire: RemoteFunction = BowRemotes.CanFire

-- Ammo Data
local Data = {}

-- Constants
local FIRE_COOLDOWN = 0.2
local ABILITY_ARROWS = 3
local ARROW_REGEN = 3


function class.GetData()
    return Data
end

-- Config
function class.PlayerAdded(player: Player)
    Data[player] = {
        AbilityArrows = ABILITY_ARROWS,
        LastFire = os.time(),
        AbilityArrowToggle = false,
    }
end

function class.PlayerRemoving(player: Player)
   if not Data[player] then return end 
   Data[player] = nil
end

-- Use
function class.Reset(player: Player)
    if not Data[player] then return end 

    local data = Data[player]
    data.AbilityArrows = ABILITY_ARROWS
    data.LastFire = os.time()
end

function class.GetAbilityArrowToggle(player: Player)
    if not Data[player] then return end 
    return Data[player].AbilityArrowToggle
end

function class.GetArrowHandler(player: Player)
    if not Data[player] then return end 

    local BowName = "Test"

    
end

function class.Fire(player: Player)
    print(`Recieved Fire Request from {player.Name}`)
    local data = Data[player]
    if not data then return {CanFire = false, Msg = "No Data!"} end

    if os.time() - data.LastFire < FIRE_COOLDOWN then return {CanFire = false, Msg = "Fire Cooldown Hit"} end
    if data.AbilityArrows <= 0 and data.AbilityArrowToggle then return {CanFire = false, Msg = "No Ability Arrows!"} end

    data.LastFire = os.time()

    if data.AbilityArrowToggle then 
        data.AbilityArrows -= 1
        UpdateAbilityArrowCountEvent:FireClient(player, data.AbilityArrows) 
    end

    return {CanFire = true, Msg = "Fired!"}
end

function class.CanFire(player: Player)
    local data = Data[player]
    if not data then warn("No Data!") return false end

    if os.time() - data.LastFire < FIRE_COOLDOWN then warn("cooldown") return false end
    if data.AbilityArrows <= 0 and data.AbilityArrowToggle then  warn("no arrow") return false end

    print("Allowing Fire")
    return true
end

function class.ToggleArrow(player: Player)
    local data = Data[player]
    if not data then warn("no data") return false end

    data.AbilityArrowToggle = not data.AbilityArrowToggle
    return data.AbilityArrowToggle
end

function class.Setup()
    ToggleArrow.OnServerInvoke = class.ToggleArrow
    CanFire.OnServerInvoke = class.CanFire
    
    while task.wait() do
        for player, data in pairs(Data) do
            data.AbilityArrows += 1
            UpdateAbilityArrowCountEvent:FireClient(player, data.AbilityArrows)
        end
    end
end

return class