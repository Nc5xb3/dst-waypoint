--[[
NStyler
By Nc5xb3
Functions sort of like a cascading style sheet
]]

local NStyler = Class(function(self)
	self.styles = {}
end)

function NStyler:AddStyle(class, styler)
	self.styles[#self.styles+1] = {["class"] = class, ["styler"] = styler}
end

function NStyler:ApplyStyle(npanel)
	if npanel.class == nil then
		return
	end
	for i,style in pairs(self.styles) do
		if style.styler ~= nil and self:Contains(npanel.class, style.class) then
			if npanel.style ~= nil and npanel.style.Kill ~= nil then
				npanel.style:Kill()
			end
			style.styler(npanel)
			if npanel.style ~= nil and npanel.style.MoveToBack ~= nil then
				npanel.style:MoveToBack()
			end
		end
		if npanel.children then
		    for k,v in pairs(npanel.children) do
				self:ApplyStyle(v)
		    end
		end
	end
end

function NStyler:Contains(class1, class2)
    for i,c in pairs(class2) do
    	local exists = false
	    for j,s in pairs(class1) do
			if string.match(s,c) then
				exists = true
				break
			end
	    end
	    if not exists then
	    	return false
	    end
    end
    return true
end

return NStyler