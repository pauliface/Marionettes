--!strict
local Packages = script.Parent.Parent.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Signal = require(Packages.Signal)

local DogMarionetteGui = require("./DogMarionetteGui")
local Settings = require("./Settings")
local createDogMarionette = require("./createDogMarionette")

type ReactRoot = {
	render: (self: any, element: any) -> (),
	unmount: (self: any) -> (),
}

return function(
	plugin: Plugin,
	panel: DockWidgetPluginGui,
	buttonClicked: Signal.Signal<>,
	setButtonActive: (active: boolean) -> ()
)
	local activeSettings = Settings.Load(plugin)
	local isOpen = false
	local reactRoot: ReactRoot? = nil

	local function updateUI()
		if isOpen then
			if not reactRoot then
				reactRoot = ReactRoblox.createRoot(panel) :: ReactRoot
			end
			reactRoot:render(React.createElement(DogMarionetteGui, {
				Settings = activeSettings,
				OnSettingChanged = function(newSettings: Settings.DogMarionetteSettings)
					activeSettings = newSettings
					updateUI()
				end,
				OnCreate = function()
					createDogMarionette({
						HeadColor    = Color3.new(activeSettings.HeadColorR,    activeSettings.HeadColorG,    activeSettings.HeadColorB),
						BodyColor    = Color3.new(activeSettings.BodyColorR,    activeSettings.BodyColorG,    activeSettings.BodyColorB),
						LegsColor    = Color3.new(activeSettings.LegsColorR,    activeSettings.LegsColorG,    activeSettings.LegsColorB),
						HandlesColor = Color3.new(activeSettings.HandlesColorR, activeSettings.HandlesColorG, activeSettings.HandlesColorB),
						OverallScale = activeSettings.OverallScale,
						LegLength    = activeSettings.LegLength,
						SnoutLength  = activeSettings.SnoutLength,
					})
				end,
			}))
		elseif reactRoot then
			reactRoot:unmount()
			reactRoot = nil
		end
	end

	-- Toggle open/closed when button is clicked
	local clickedCn = buttonClicked:Connect(function()
		isOpen = not isOpen
		setButtonActive(isOpen)
		panel.Enabled = isOpen
		updateUI()
	end)

	-- Track if user closes the panel via the X button
	panel:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not panel.Enabled and isOpen then
			isOpen = false
			setButtonActive(false)
			updateUI()
		end
	end)

	-- If the panel was already open when the plugin first loaded, show the UI
	if panel.Enabled then
		isOpen = true
		setButtonActive(true)
		updateUI()
	end

	plugin.Unloading:Connect(function()
		Settings.Save(plugin, activeSettings)
		clickedCn:Disconnect()
		if reactRoot then
			reactRoot:unmount()
			reactRoot = nil
		end
	end)
end
