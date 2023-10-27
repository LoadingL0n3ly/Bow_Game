local class = {}
class.__index = class

function class:Hit()
    -- hit code goes here!
end

function class.New(ActiveCast)
    local Data = ActiveCast.UserData
    Data.Owner = "ub"

    setmetatable(Data, class)
end

-- outside
-- ActiveCast.UserData:Hit()

return class