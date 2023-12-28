local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage.Common

local ArrowStorage = Common.Arrow

return  {
    ["Test"] = {
        Purchase = {
            Price = 0,
            Gamepass = nil,
        },

        Name = "Test Arrow",
        Description = "Test Arrow Description",
        Module = ArrowStorage.TestArrow,
    }
}