--!strict
local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Packages

local React = require(Packages.React)
local e = React.createElement

local Colors = require("./Colors")
local NumberInput = require("./NumberInput")

local function ColorInput(props: {
	Label: string,
	Color: Color3,
	OnColorChanged: (Color3) -> (),
	LayoutOrder: number?,
})
	local r = math.round(props.Color.R * 255)
	local g = math.round(props.Color.G * 255)
	local b = math.round(props.Color.B * 255)

	local function clamp(v: number): number
		return math.max(0, math.min(255, math.round(v)))
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3),
		}),
		-- Label row with color swatch
		Header = e("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			}),
			Label = e("TextLabel", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = props.Label,
				TextColor3 = Colors.OFFWHITE,
				Font = Enum.Font.SourceSansBold,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
			}),
			Swatch = e("Frame", {
				Size = UDim2.fromOffset(20, 16),
				BackgroundColor3 = props.Color,
				LayoutOrder = 2,
			}, {
				Corner = e("UICorner", { CornerRadius = UDim.new(0, 3) }),
				Stroke = e("UIStroke", { Color = Colors.OFFWHITE, Thickness = 1 }),
			}),
		}),
		-- R G B input row
		Inputs = e("Frame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 3),
			}),
			RInput = e(NumberInput, {
				Label = "R",
				Value = r,
				ChipColor = Color3.fromRGB(220, 60, 60),
				Grow = true,
				ValueEntered = function(v: number)
					local clamped = clamp(v)
					props.OnColorChanged(Color3.new(clamped / 255, props.Color.G, props.Color.B))
					return clamped
				end,
				LayoutOrder = 1,
			}),
			GInput = e(NumberInput, {
				Label = "G",
				Value = g,
				ChipColor = Color3.fromRGB(60, 200, 60),
				Grow = true,
				ValueEntered = function(v: number)
					local clamped = clamp(v)
					props.OnColorChanged(Color3.new(props.Color.R, clamped / 255, props.Color.B))
					return clamped
				end,
				LayoutOrder = 2,
			}),
			BInput = e(NumberInput, {
				Label = "B",
				Value = b,
				ChipColor = Color3.fromRGB(60, 60, 220),
				Grow = true,
				ValueEntered = function(v: number)
					local clamped = clamp(v)
					props.OnColorChanged(Color3.new(props.Color.R, props.Color.G, clamped / 255))
					return clamped
				end,
				LayoutOrder = 3,
			}),
		}),
	})
end

return ColorInput
