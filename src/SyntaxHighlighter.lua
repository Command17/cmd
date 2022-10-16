local syntaxHighlighter = {}
syntaxHighlighter.Colors = {
	Command = Color3.fromRGB(255, 112, 112),
	Number = Color3.fromRGB(255, 170, 0),
	Link = Color3.fromRGB(0, 170, 255)
}

function syntaxHighlighter:colorToString(color: Color3)
	return string.format("rgb(%s,%s,%s)", tostring(math.round(color.R * 255)),tostring(math.round(color.G * 255)), tostring(math.round(color.B * 255)))
end

function syntaxHighlighter:highlight(s: string)
	local sSplit = string.split(s, " ")
	
	if sSplit == nil then
		sSplit = {[1] = s}
	end
	
	local resultS = ""
	
	for i, v in pairs(sSplit) do		
		if i == 1 then
			resultS = resultS.. '<font color="'.. syntaxHighlighter:colorToString(syntaxHighlighter.Colors.Command) ..'">' .. sSplit[i] .. "</font> "
		else
			if tonumber(sSplit[i]) ~= nil then
				resultS = resultS.. '<font color="'.. syntaxHighlighter:colorToString(syntaxHighlighter.Colors.Number) ..'">' .. sSplit[i] .. "</font> "
			elseif string.sub(sSplit[i], 1, 8) == "https://" then
				resultS = resultS.. '<font color="'.. syntaxHighlighter:colorToString(syntaxHighlighter.Colors.Link) ..'">' .. sSplit[i] .. "</font> "
			else
				resultS = resultS .. sSplit[i] .. " "
			end
		end
	end
	
	return resultS
end

return syntaxHighlighter
