--!strict
local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Packages

local React = require(Packages.React)
local e = React.createElement

local UserInputService = game:GetService("UserInputService")

local Colors = require("./Colors")

local function LabeledSlider(props: {
	Label: string,
	Value: number, -- 0 to 255
	FillColor: Color3,
	OnValueChanged: (number) -> (),
	LayoutOrder: number?,
})
	local trackRef = React.useRef(nil :: Frame?)
	local draggingRef = React.useRef(false)
	local onValueChangedRef = React.useRef(props.OnValueChanged)
	onValueChangedRef.current = props.OnValueChanged

	local function getValueFromX(x: number): number
		local track = trackRef.current
		if not track then return 0 end
		local fraction = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		return math.round(fraction * 255)
	end

	React.useEffect(function()
		local conn1 = UserInputService.InputChanged:Connect(function(input: InputObject)
			if not draggingRef.current then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			onValueChangedRef.current(getValueFromX(input.Position.X))
		end)
		local conn2 = UserInputService.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingRef.current = false
			end
		end)
		return function()
			conn1:Disconnect()
			conn2:Disconnect()
		end
	end, {})

	local fillFraction = props.Value / 255

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
		LabelText = e("TextLabel", {
			Size = UDim2.fromOffset(12, 18),
			BackgroundTransparency = 1,
			Text = props.Label,
			TextColor3 = props.FillColor,
			Font = Enum.Font.SourceSansBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 1,
		}),
		Track = e("Frame", {
			Size = UDim2.fromOffset(0, 12),
			BackgroundColor3 = Colors.DISABLED_GREY,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			ref = trackRef,
			[React.Event.InputBegan] = function(_, input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingRef.current = true
					onValueChangedRef.current(getValueFromX(input.Position.X))
				end
			end,
		}, {
			Corner = e("UICorner", { CornerRadius = UDim.new(0, 3) }),
			Flex = e("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow }),
			Fill = e("Frame", {
				Size = UDim2.new(fillFraction, 0, 1, 0),
				BackgroundColor3 = props.FillColor,
				BorderSizePixel = 0,
			}, {
				Corner = e("UICorner", { CornerRadius = UDim.new(0, 3) }),
			}),
		}),
		ValueText = e("TextLabel", {
			Size = UDim2.fromOffset(28, 18),
			BackgroundTransparency = 1,
			Text = tostring(props.Value),
			TextColor3 = Colors.OFFWHITE,
			Font = Enum.Font.SourceSans,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
			LayoutOrder = 3,
		}),
	})
end

return LabeledSlider
