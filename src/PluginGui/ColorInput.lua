--!strict
local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Packages

local React = require(Packages.React)
local e = React.createElement

local Colors = require("./Colors")
local LabeledSlider = require("./LabeledSlider")

local function ColorInput(props: {
	Label: string,
	Color: Color3,
	OnColorChanged: (Color3) -> (),
	LayoutOrder: number?,
})
	local r = math.round(props.Color.R * 255)
	local g = math.round(props.Color.G * 255)
	local b = math.round(props.Color.B * 255)

	return e("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		ListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
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
		-- R G B sliders
		RSlider = e(LabeledSlider, {
			Label = "R",
			Value = r,
			FillColor = Color3.fromRGB(220, 60, 60),
			OnValueChanged = function(v: number)
				props.OnColorChanged(Color3.new(v / 255, props.Color.G, props.Color.B))
			end,
			LayoutOrder = 2,
		}),
		GSlider = e(LabeledSlider, {
			Label = "G",
			Value = g,
			FillColor = Color3.fromRGB(60, 200, 60),
			OnValueChanged = function(v: number)
				props.OnColorChanged(Color3.new(props.Color.R, v / 255, props.Color.B))
			end,
			LayoutOrder = 3,
		}),
		BSlider = e(LabeledSlider, {
			Label = "B",
			Value = b,
			FillColor = Color3.fromRGB(60, 60, 220),
			OnValueChanged = function(v: number)
				props.OnColorChanged(Color3.new(props.Color.R, props.Color.G, v / 255))
			end,
			LayoutOrder = 4,
		}),
	})
end

return ColorInput
