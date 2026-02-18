--!strict
local kSettingsKey = "dogMarionetteState"

export type DogMarionetteSettings = {
	HeadColorR: number,
	HeadColorG: number,
	HeadColorB: number,
	BodyColorR: number,
	BodyColorG: number,
	BodyColorB: number,
	LegsColorR: number,
	LegsColorG: number,
	LegsColorB: number,
	HandlesColorR: number,
	HandlesColorG: number,
	HandlesColorB: number,
	OverallScale: number,
	LegLength: number,
	SnoutLength: number,
}

local function Load(plugin: Plugin): DogMarionetteSettings
	local raw = plugin:GetSetting(kSettingsKey) or {}
	return {
		HeadColorR = raw.HeadColorR or 0.867,
		HeadColorG = raw.HeadColorG or 0.173,
		HeadColorB = raw.HeadColorB or 0.173,
		BodyColorR = raw.BodyColorR or 0.698,
		BodyColorG = raw.BodyColorG or 0.130,
		BodyColorB = raw.BodyColorB or 0.130,
		LegsColorR = raw.LegsColorR or 0.600,
		LegsColorG = raw.LegsColorG or 0.110,
		LegsColorB = raw.LegsColorB or 0.110,
		HandlesColorR = raw.HandlesColorR or 0.800,
		HandlesColorG = raw.HandlesColorG or 0.420,
		HandlesColorB = raw.HandlesColorB or 0.110,
		OverallScale = raw.OverallScale or 1.0,
		LegLength = raw.LegLength or 1.0,
		SnoutLength = raw.SnoutLength or 1.0,
	}
end

local function Save(plugin: Plugin, settings: DogMarionetteSettings)
	plugin:SetSetting(kSettingsKey, {
		HeadColorR = settings.HeadColorR,
		HeadColorG = settings.HeadColorG,
		HeadColorB = settings.HeadColorB,
		BodyColorR = settings.BodyColorR,
		BodyColorG = settings.BodyColorG,
		BodyColorB = settings.BodyColorB,
		LegsColorR = settings.LegsColorR,
		LegsColorG = settings.LegsColorG,
		LegsColorB = settings.LegsColorB,
		HandlesColorR = settings.HandlesColorR,
		HandlesColorG = settings.HandlesColorG,
		HandlesColorB = settings.HandlesColorB,
		OverallScale = settings.OverallScale,
		LegLength = settings.LegLength,
		SnoutLength = settings.SnoutLength,
	})
end

return {
	Load = Load,
	Save = Save,
}
