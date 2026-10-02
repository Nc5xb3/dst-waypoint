--[[
NMapIconTemplate
By Nc5xb3
refer to NMapIconTemplateManager
]]

local NMapIconTemplate = Class(function(self)
    self.worldposition = Vector3(0,0,0)
    self.widget = nil
end)

function NMapIconTemplate:SetWorldPosition(x,y,z)
    self.worldposition = Vector3(x,y,z)
end

function NMapIconTemplate:SetWidget(func)
    self.widget = func
end

return NMapIconTemplate