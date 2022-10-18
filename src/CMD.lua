local HttpService = game:GetService("HttpService")

local cmd = {}
local cmdInterface = {}
cmd.Dir = "game"
cmd.Version = "1.2.0"
cmd.LoadedPackages = {}

local Plugin = script.Parent
local Modules = Plugin.Modules
local Packages = Plugin.Packages
local Events = Plugin.Events

function cmd:runCommandPerString(s: string)
	local CommandSplit = string.split(s, " ")
	
	if not CommandSplit then
		CommandSplit = {[1] = s}
	end
	
	local Package = nil
	
	for i, v in ipairs(cmd.LoadedPackages) do
		if v[CommandSplit[1]] then
			Package = v
		end
	end
	
	local args = table.clone(CommandSplit)
	
	table.remove(args, 1)
	
	if Package ~= nil then
		if typeof(Package[CommandSplit[1]]) == "function" then
			Package[CommandSplit[1]](args, cmdInterface, cmd)

			return
		else
			if Package[CommandSplit[1]][CommandSplit[2]] then
				table.remove(args, 1)
				
				Package[CommandSplit[1]][CommandSplit[2]](args, cmdInterface, cmd)
			else
				cmdInterface:newMsg("Could not find sub-command \"" .. CommandSplit[2] .. "\".")
			end
			
			return
		end
	end
	
	cmdInterface:newMsg("Could not find command \"" .. CommandSplit[1] .. "\".")
end

function cmd:loadPackages()
	for i, Package in pairs(Packages:GetChildren()) do
		cmd:addPackage(Package)
	end
end

function cmd:addPackage(Package: ModuleScript)
	local reqPackage = require(Package)
	reqPackage.p = Package

	table.insert(cmd.LoadedPackages, reqPackage)
	
	Events.PackageAdded:Fire(Package)
end

function cmd:removePackage(Package: ModuleScript)
	for i, v in ipairs(cmd.LoadedPackages) do
		if v.p == Package then
			table.remove(cmd.LoadedPackages, i)
		end
	end
	
	Events.PackageRemoved:Fire(Package)
end

function cmd:createInterface(Widget)
	cmdInterface:createInterface(Widget)
	cmdInterface:newInput()
end

function cmd:getGameObjectFromDir()
	local dirSplit = string.split(cmd.Dir, "/")
	
	if not dirSplit then
		dirSplit = {[1] = cmd.Dir}
	end
	
	local lastDir = game
	
	for i, v in pairs(dirSplit) do
		if i ~= 1 then
			lastDir = lastDir:FindFirstChild(v)
		end
	end
	
	return lastDir
end

function cmd:setFont(font: EnumItem)
	cmdInterface:setFont(font)
end

function cmd:setBackgroundColor(color: Color3)
	cmdInterface:setBackgroundColor(color)
end

-- Interface --

local SyntaxHighlighter = require(script.SyntaxHighlighter)
local Fusion = require(Modules.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local State = Fusion.State
local Computed = Fusion.Computed

local CurrentCommandBar = nil
local CustomBackgroundColor = false

local InterfaceChildrenT = {}
local InterfaceChildren = State({})

local BackgroundColor = State(settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground))
local TextColor = State(settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText))
local fontState = State(Enum.Font.SourceSans)

local BackgroundStyle = Computed(function()
	return BackgroundColor:get()
end)

local TextStyle = Computed(function()
	return TextColor:get()
end)

local FontStyle = Computed(function()
	return fontState:get()
end)

local Lines = 0

function cmdInterface:getFont()
	return fontState:get()
end

function cmdInterface:setFont(font: EnumItem)
	fontState:set(font)
	
	Events.FontChanged:Fire(font)
end

function cmdInterface:setBackgroundColor(color: Color3)
	CustomBackgroundColor = true
	
	BackgroundColor:set(color)
	
	Events.BackgroundChanged:Fire(color)
end

function cmdInterface:useStudioBackgroundColor()
	CustomBackgroundColor = false
	
	BackgroundColor:set(settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground))
	
	Events.BackgroundChanged:Fire(nil)
end

function cmdInterface:getBackgroundColor()
	return BackgroundColor:get()
end

function cmdInterface:createInterface(Widget)
	local Ui = New "ScrollingFrame" {
		Parent = Widget,

		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = BackgroundStyle,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.XY,

		[Children] = InterfaceChildren
	}

	Ui = cmdInterface.Ui

	cmdInterface:newMsg("Running CMD v" .. cmd.Version .. ". Run clear to clear cmd. Run help to see commands.")
	
	local plugin_version = "1.2.0"
	
	local succes, err = pcall(function()
		plugin_version = HttpService:GetAsync("https://raw.githubusercontent.com/Command17/cmd/main/version.txt")
	end)
	
	plugin_version = string.gsub(plugin_version, "%s", "")
	
	if succes then
		if plugin_version ~= cmd.Version then
			cmdInterface:newMsg("CMD v" .. plugin_version .. "is now available", Color3.fromRGB(255, 255, 0))
		end
	end
end

function cmdInterface:newMsg(msg: string, color: Color3?)
	if color == nil then
		color = TextStyle
	end

	local MSG = New "TextLabel" {
		Name = "msg",

		AutomaticSize = Enum.AutomaticSize.X,
		Text = msg,
		TextSize = 16,
		Font = FontStyle,
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
		TextColor3 = color,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(0, 0, 0, Lines * 25),
		BackgroundTransparency = 1,
	}

	cmdInterface:_addParent(MSG)

	Lines += 1
end

function cmdInterface:_removeParent(v)
	for i, _v in ipairs(InterfaceChildrenT) do
		if _v == v then
			table.remove(InterfaceChildrenT, i)
		end
	end

	InterfaceChildren:set({InterfaceChildrenT})
end

function cmdInterface:_addParent(v)
	table.insert(InterfaceChildrenT, v)

	InterfaceChildren:set({InterfaceChildrenT})
end

function cmdInterface:clearInput()
	pcall(function()
		if CurrentCommandBar then
			cmdInterface:_removeParent(CurrentCommandBar)

			CurrentCommandBar:Destroy()
		end
	end)
end

function cmdInterface:newInput()
	local CommandBarText = State("")
	local Dir = State("")
	local DirTextSize = State(UDim2.new(0, 50, 1, 0))

	local CommandBoxPos = Computed(function()
		return UDim2.new(0, DirTextSize:get().X.Offset, 0, 0)
	end)

	local FullCommandBarText = State("")

	local FullText = Computed(function()
		return FullCommandBarText:get()
	end)

	local DirComputed = Computed(function()
		return string.format("%s> ", Dir:get())
	end)

	local CommandBar = New "Frame" {
		Name = "CommandBar",

		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(0, 0, 0, Lines * 25),
		BackgroundTransparency = 1,

		[Children] = {
			New "TextLabel" {
				Name = "Dir",
				
				AutomaticSize = Enum.AutomaticSize.X,
				Text = DirComputed,
				TextSize = 16,
				Font = FontStyle,
				TextColor3 = TextStyle,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 50, 1, 0),
				
				[OnChange "TextBounds"] = function(newBounds)
					DirTextSize:set(UDim2.new(0, newBounds.X + 5, 1, 0))
				end,
			},

			New "TextBox" {
				Name = "CommandBox",

				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 16,
				Font = FontStyle,
				ClearTextOnFocus = false,
				TextColor3 = BackgroundStyle,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 50, 1, 0),
				Position = CommandBoxPos,

				[OnEvent "FocusLost"] = function(Enter)
					if Enter then
						cmdInterface:newMsg(string.format("%s> %s", Dir:get(), FullCommandBarText:get()))

						cmd:runCommandPerString(CommandBarText:get())

						cmdInterface:newInput()
					end
				end,

				[OnChange "Text"] = function(newText)
					CommandBarText:set(newText)

					FullCommandBarText:set(SyntaxHighlighter:highlight(newText))
				end
			},

			New "TextLabel" {
				Name = "CommandBoxLabel",

				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 16,
				Font = FontStyle,
				RichText = true,
				Text = FullText,
				TextColor3 = TextStyle,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 50, 1, 0),
				Position = CommandBoxPos,
			}
		}
	}
	
	cmdInterface:clearInput()

	CurrentCommandBar = CommandBar

	cmdInterface:_addParent(CommandBar)
	
	Dir:set(cmd.Dir)
end

function cmdInterface:clear()
	for i, v in pairs(InterfaceChildrenT) do
		v:Destroy()
	end
	
	InterfaceChildrenT = {}
	InterfaceChildren:set({})
	
	Lines = 0
	
	cmdInterface:newMsg("cleared cmd.")
	
	cmdInterface:newInput()
end

settings().Studio.ThemeChanged:Connect(function()
	if CustomBackgroundColor then
		BackgroundColor:set(settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground))
	end
	TextColor:set(settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText))
end)

return cmd
