local HttpService = game:GetService("HttpService")

local NonDeletablePackages = {
	["BuilInCommands"] = script,
}

local Fonts = {}

local BackgroundColors = {}

for i, v in ipairs(Enum.Font:GetEnumItems()) do
	local font = string.split(tostring(v), ".")[3]
	
	Fonts[font] = v
end

return {
	["help"] = function(args, cmdInterface, cmd)
		for i, Package in ipairs(cmd.LoadedPackages) do
			for i, v in pairs(Package) do
				if typeof(v) == "table" then
					cmdInterface:newMsg(i .. ":", Color3.fromRGB(0, 255, 0))
					
					for _i, _v in pairs(v) do
						cmdInterface:newMsg("-" .. _i, Color3.fromRGB(0, 255, 0))
					end
				elseif typeof(v) == "function" then
					cmdInterface:newMsg(i, Color3.fromRGB(0, 255, 0))
				end
			end
		end
	end,
	
	["settings"] = {
		["getFont"] = function(args, cmdInterface, cmd)
			cmdInterface:newMsg("The current font is: " .. string.split(tostring(cmdInterface:getFont()), ".")[3])
		end,
		
		["setFont"] = function(args, cmdInterface, cmd)
			local font = args[1]
			
			if font then
				if Fonts[font] then
					cmdInterface:setFont(Fonts[font])
					
					cmdInterface:newMsg("Changed font")
				else
					cmdInterface:newMsg("Could not find font")
				end
			else
				cmdInterface:newMsg("An Argument is missing!")
			end
		end,
		
		["getFonts"] = function(args, cmdInterface, cmd)
			for i, v in pairs(Fonts) do
				cmdInterface:newMsg(i, Color3.fromRGB(0, 255, 0))
			end
		end,
		
		["getBackgroundColor"] = function(args, cmdInterface, cmd)
			local color = cmdInterface:getBackgroundColor()
			
			cmdInterface:newMsg(string.format("The current background color is: %s, %s, %s", tostring(math.round(color.R * 255)), tostring(math.round(color.G * 255)), tostring(math.round(color.B * 255))))
		end,
		
		["setBackgroundColor"] = function(args, cmdInterface, cmd)
			local color1 = args[1]
			local color2 = args[2]
			local color3 = args[3]
			
			if color1 then
				if color1 == "Studio" then
					cmdInterface:useStudioBackgroundColor()
				elseif color1 and color2 and color3 then
					local c1 = tonumber(color1)
					local c2 = tonumber(color2)
					local c3 = tonumber(color3)
					
					if c1 and c2 and c3 then
						local Color = Color3.fromRGB(c1, c2, c3)
						
						cmdInterface:setBackgroundColor(Color)
						
						cmdInterface:newMsg(string.format("Set background color to: %s, %s, %s", c1, c2, c3))
					else
						cmdInterface:newMsg("Argument(s) are wrong")
					end
				else
					cmdInterface:newMsg("Argument(s) are missing!")
				end
			else
				cmdInterface:newMsg("Argument(s) are missing!")
			end
		end,
	},
	
	["version"] = {
		["latest"] = function(args, cmdInterface, cmd)
			local latest = nil
			
			local succes, err = pcall(function()
				latest = HttpService:GetAsync("https://raw.githubusercontent.com/Command17/cmd/main/version.txt")
			end)
			
			if succes and latest then
				cmdInterface:newMsg("Latest version is: " .. latest)
			else
				cmdInterface:newMsg("Could not get latest version")
			end
		end,
		
		["current"] = function(args, cmdInterface, cmd)
			cmdInterface:newMsg("Current version: " .. cmd.Version)
		end,
	},
	
	["cd"] = function(args, cmdInterface, cmd)
		if args[1] then
			if args[1] == ".." then
				local dirSplit = string.split(cmd.Dir, "/")

				local newDir = ""

				if not dirSplit or #dirSplit == 1 then
					cmdInterface:newMsg("Cannot change directory!", Color3.fromRGB(255, 0 ,0))
					
					return
				else
					for i, v in pairs(dirSplit) do
						if i == (#dirSplit - 1) then
							newDir = newDir .. dirSplit[i]
						elseif i < (#dirSplit - 1) then
							newDir = newDir .. dirSplit[i] .. "/"
						end
					end
				end

				cmd.Dir = newDir
			else
				local newDir = cmd.Dir

				local gameObject = cmd:getGameObjectFromDir()

				if gameObject then
					local newGameObject = gameObject:FindFirstChild(args[1])

					if newGameObject then
						newDir = newDir .. "/" .. tostring(newGameObject.Name)

						cmd.Dir = newDir
					else
						cmdInterface:newMsg("Cannot change directory!", Color3.fromRGB(255, 0 ,0))
					end
				end
			end
		else
			cmdInterface:newMsg("An Argument is missing!")
		end
	end,
	
	["packages"] = {
		["add"] = function(args, cmdInterface, cmd)
			local Package = cmd:getGameObjectFromDir()

			if Package and Package:IsA("ModuleScript") then
				local package = Package:Clone()
				package.Parent = script.Parent
				
				cmd:addPackage(package)

				cmdInterface:newMsg("Added \"" .. package.Name .. "\" to Packages")
			else
				cmdInterface:newMsg("Could not add \"" .. Package.Name .. "\" to Packages")
			end
		end,

		["remove"] = function(args, cmdInterface, cmd)
			local Name = args[1]

			if Name then
				for i, Package in pairs(script.Parent:GetChildren()) do
					if Package.Name == Name then
						if NonDeletablePackages[Package.Name] and Package == NonDeletablePackages[Package.Name] then
							cmdInterface:newMsg("Cannot delete package \"" .. Package.Name .. "\".", Color3.fromRGB(255, 0, 0))
						else
							cmd:removePackage(Package)

							cmdInterface:newMsg("Removed \"" .. Package.Name .. "\".")
						end
					else
						cmdInterface:newMsg("Could not find \"" .. Name .. "\".")
					end
				end
			else
				cmdInterface:newMsg("An Argument are missing!")
			end
		end,

		["get"] = function(args, cmdInterface, cmd)
			for i, v in pairs(script.Parent:GetChildren()) do
				cmdInterface:newMsg(v.Name, Color3.fromRGB(0, 255, 0))
			end
		end,

		["fromHttp"] = function(args, cmdInterface, cmd)
			local link = args[1]
			local Name = args[2]

			if link and Name then
				local code

				local succes, err = pcall(function()
					code = HttpService:GetAsync(link)
				end)

				if succes then
					cmdInterface:newMsg("getting code from: " .. link)

					local Package = Instance.new("ModuleScript", script.Parent)
					Package.Parent = script.Parent
					Package.Name = Name
					Package.Source = code

					cmd:addPackage(Package)

					cmdInterface:newMsg("Added package from: " .. link)
				else
					cmdInterface:newMsg("An error happend while getting code: " .. tostring(err), Color3.fromRGB(255, 0, 0))
				end
			else
				cmdInterface:newMsg("Argument(s) are missing!")
			end
		end,
	},
	
	["clear"] = function(rags, cmdInterface)
		cmdInterface:clear()
	end,
}
