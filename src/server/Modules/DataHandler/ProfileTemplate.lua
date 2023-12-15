--!strict

type ProfileTemplate = {
	Stats: {
		Kills: number,
	},

	EquippedBow: string,
	EquippedArrow: string,

	Inventory: {
		Bows: {
			[string]: {
				Level: number,
			}
		},

		Arrows: {
			[string]: boolean,
		},
	}
}

local ProfileTemplate: ProfileTemplate = {
	Stats = {
		Kills = 0,
	},

	Currency = {
		Gold = 0,
	},

	EquippedBow = "Test",
	EquippedArrow = "Test",

	Inventory = {
		Bows = {
			Test = true
		},

		Arrows = {
			Test = {
				Level = 1,
			}
		},
	}

}

return ProfileTemplate