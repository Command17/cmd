local HttpService = game:GetService("HttpService")

local Plugin = script.Parent
local Packages = Plugin.Packages

local PluginBar = plugin:CreateToolbar("CMD by baum")
local PluginButton = PluginBar:CreateButton("CMD_Button", "Open CMD", "http://www.roblox.com/asset/?id=11295128691", "CMD")

local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 500, 250, 250, 125)
local Widget = plugin:CreateDockWidgetPluginGui("CMDWidget", WidgetInfo)

local Events = Plugin.Events
local CMD = require(Plugin.CMD)

local PackagesToSave = {}

local EXTRA_PACKAGES_KEY = "cmd_extra_packages"
local FONT_KEY = "cmd_font"

Widget.Title = "CMD"

CMD:loadPackages()
CMD:createInterface(Widget)

Widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	PluginButton:SetActive(Widget.Enabled)
end)

PluginButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)

Events.PackageAdded.Event:Connect(function(Package)
	PackagesToSave[Package.Name] = Package.Source
	
	plugin:SetSetting(EXTRA_PACKAGES_KEY, HttpService:JSONEncode(PackagesToSave))
end)

Events.PackageRemoved.Event:Connect(function(Package)
	PackagesToSave[Package] = nil
end)

Events.FontChanged.Event:Connect(function(font)
	plugin:SetSetting(FONT_KEY, string.split(tostring(font), ".")[3])
end)

local succes, err = pcall(function()
	PackagesToSave = HttpService:JSONDecode(plugin:GetSetting(EXTRA_PACKAGES_KEY))

	for i, PackageSource in pairs(PackagesToSave) do
		if PackageSource ~= nil then
			local Package = Instance.new("ModuleScript")
			Package.Name = i
			Package.Source = PackageSource
			Package.Parent = Packages

			CMD:addPackage(Package)
		end
	end
end)

local succes, err = pcall(function()
	local data = plugin:GetSetting(FONT_KEY)
	
	if data then
		local font = Enum.Font[data]

		CMD:setFont(font)
	end
end)
