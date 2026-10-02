--[[
NMapIconTemplateManager
By Nc5xb3
refer to NMapWidget
]]

local NMapIconTemplateManager = Class(function(self)
	self.templates = {}
end)

-- Should take in NMapIconTemplate
function NMapIconTemplateManager:AddTemplate(template)
	table.insert(self.templates, template)

	return template
end

function NMapIconTemplateManager:RemoveTemplate(template)
	if not self.templates then return end

	local index = nil
	for i,v in pairs(self.templates) do
		if v == template then
			index = i
			break
		end
	end
	if index then
		table.remove(self.templates, index)
	end
end

function NMapIconTemplateManager:HasTemplate(template)
	if not self.templates then return end
	for i,v in pairs(self.templates) do
		if v == template then
			return true
		end
	end
	return false
end

function NMapIconTemplateManager:GetTemplate(template)
	if not self.templates then return end
	for i,v in pairs(self.templates) do
		if v == template then
			return v
		end
	end
	return nil
end

return NMapIconTemplateManager