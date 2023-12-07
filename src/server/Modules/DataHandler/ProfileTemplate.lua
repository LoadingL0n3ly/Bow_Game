--!strict

type ProfileTemplate = {
	Stats: {
		Kills: number,
	},
}

local ProfileTemplate: ProfileTemplate = {
	Stats = {
		Kills = 0,
	},
}

return ProfileTemplate