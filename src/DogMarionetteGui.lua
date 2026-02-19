--!strict
local Packages = script.Parent.Parent.Packages

local React = require(Packages.React)
local e = React.createElement

local Colors = require("./PluginGui/Colors")
local SubPanel = require("./PluginGui/SubPanel")
local OperationButton = require("./PluginGui/OperationButton")
local NumberInput = require("./PluginGui/NumberInput")
local ColorInput = require("./PluginGui/ColorInput")
local Settings = require("./Settings")

local function DogMarionetteGui(props: {
	Settings: Settings.DogMarionetteSettings,
	OnSettingChanged: (Settings.DogMarionetteSettings) -> (),
	OnCreate: () -> (),
})
	local s = props.Settings

	local function clampScale(v: number): number
		return math.max(0.1, math.min(10, v))
	end

	local order = 0
	local function nextOrder(): number
		order += 1
		return order
	end

	return e("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colors.BLACK,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Colors.OFFWHITE,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.fromScale(1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, {
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),

		-- Colors section
		ColorsPanel = e(SubPanel, {
			Title = "Colors",
			Padding = UDim.new(0, 10),
			LayoutOrder = nextOrder(),
		}, {
			HeadColor = e(ColorInput, {
				Label = "Head",
				Color = Color3.new(s.HeadColorR, s.HeadColorG, s.HeadColorB),
				OnColorChanged = function(c: Color3)
					local n = table.clone(s)
					n.HeadColorR = c.R
					n.HeadColorG = c.G
					n.HeadColorB = c.B
					props.OnSettingChanged(n)
				end,
				LayoutOrder = 1,
			}),
			BodyColor = e(ColorInput, {
				Label = "Body & Tail",
				Color = Color3.new(s.BodyColorR, s.BodyColorG, s.BodyColorB),
				OnColorChanged = function(c: Color3)
					local n = table.clone(s)
					n.BodyColorR = c.R
					n.BodyColorG = c.G
					n.BodyColorB = c.B
					props.OnSettingChanged(n)
				end,
				LayoutOrder = 2,
			}),
			LegsColor = e(ColorInput, {
				Label = "Legs",
				Color = Color3.new(s.LegsColorR, s.LegsColorG, s.LegsColorB),
				OnColorChanged = function(c: Color3)
					local n = table.clone(s)
					n.LegsColorR = c.R
					n.LegsColorG = c.G
					n.LegsColorB = c.B
					props.OnSettingChanged(n)
				end,
				LayoutOrder = 3,
			}),
			HandlesColor = e(ColorInput, {
				Label = "Handles",
				Color = Color3.new(s.HandlesColorR, s.HandlesColorG, s.HandlesColorB),
				OnColorChanged = function(c: Color3)
					local n = table.clone(s)
					n.HandlesColorR = c.R
					n.HandlesColorG = c.G
					n.HandlesColorB = c.B
					props.OnSettingChanged(n)
				end,
				LayoutOrder = 4,
			}),
		}),

		-- Sizes section
		SizesPanel = e(SubPanel, {
			Title = "Sizes",
			Padding = UDim.new(0, 8),
			LayoutOrder = nextOrder(),
		}, {
			OverallScale = e(NumberInput, {
				Label = "Overall Scale",
				Value = s.OverallScale,
				ValueEntered = function(v: number)
					local clamped = clampScale(v)
					local n = table.clone(s)
					n.OverallScale = clamped
					props.OnSettingChanged(n)
					return clamped
				end,
				LayoutOrder = 1,
			}),
			LegLength = e(NumberInput, {
				Label = "Leg Length",
				Value = s.LegLength,
				ValueEntered = function(v: number)
					local clamped = clampScale(v)
					local n = table.clone(s)
					n.LegLength = clamped
					props.OnSettingChanged(n)
					return clamped
				end,
				LayoutOrder = 2,
			}),
			SnoutLength = e(NumberInput, {
				Label = "Snout Length",
				Value = s.SnoutLength,
				ValueEntered = function(v: number)
					local clamped = clampScale(v)
					local n = table.clone(s)
					n.SnoutLength = clamped
					props.OnSettingChanged(n)
					return clamped
				end,
				LayoutOrder = 3,
			}),
		}),

		-- Create button
		CreateButton = e(OperationButton, {
			Text = "Create Dog Marionette",
			Color = Color3.fromRGB(0, 130, 60),
			Disabled = false,
			Height = 40,
			LayoutOrder = nextOrder(),
			OnClick = props.OnCreate,
		}),
	})
end

return DogMarionetteGui
