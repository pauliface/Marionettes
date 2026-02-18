local COMBINE_TOOLBAR = false

local Signal = require(script.Parent.Packages.Signal)

local TOOLTIP = "Create dog marionettes in the workspace."
local RIBBON_ICON = ""

local setButtonActive: (active: boolean) -> () = nil
local buttonClicked = Signal.new()

if COMBINE_TOOLBAR then
	local createSharedToolbar = require(script.Parent.Packages.createSharedToolbar)
	local toolbarSettings = {
		ButtonName = "DogMarionette",
		ButtonTooltip = TOOLTIP,
		ButtonIcon = RIBBON_ICON,
		ToolbarName = "GeomTools",
		CombinerName = "GeomToolsToolbar",
		ClickedFn = function()
			buttonClicked:Fire()
		end,
	}
	createSharedToolbar(plugin, toolbarSettings)
	function setButtonActive(active: boolean)
		assert(toolbarSettings.Button):SetActive(active)
	end
else
	local toolbar = plugin:CreateToolbar("DogMarionette")
	local button = toolbar:CreateButton("openDogMarionette", TOOLTIP, RIBBON_ICON, "Dog Marionette")
	local clickCn = button.Click:Connect(function()
		buttonClicked:Fire()
	end)
	function setButtonActive(active: boolean)
		button:SetActive(active)
	end
	plugin.Unloading:Connect(function()
		clickCn:Disconnect()
	end)
end

local params = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	260,
	420,
	220,
	300
)
local panel = plugin:CreateDockWidgetPluginGuiAsync("DogMarionettePanel", params)
panel.Title = "Dog Marionette"
panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local loaded = false
local function doInitialLoad()
	loaded = true
	require(script.Parent.Src.main)(plugin, panel, buttonClicked, setButtonActive)
end

local clickedCn = buttonClicked:Connect(function()
	if not loaded then
		doInitialLoad()
		buttonClicked:Fire()
	end
end)

if panel.Enabled then
	doInitialLoad()
end

plugin.Deactivation:Connect(function()
	clickedCn:Disconnect()
end)
