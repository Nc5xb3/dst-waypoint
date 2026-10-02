--[[
NPanel
By Nc5xb3
Basis of a panel, since widget does not have size attributes,
useful for NStyler to apply styles
]]
local Widget = require "widgets/widget"

local NPanel = Class(Widget, function(self, name)
	Widget._ctor(self, name)
	self.class = {"NPanel"}
	self.inst.size={0,0}
end)

function NPanel:AddClass(class)
	table.insert(self.class, class)
end

function NPanel:SetSize(w,h)
    if type(w) == "number" then
		self.inst.size={w,h}
    else
		self.inst.size={w[1],w[2]}
    end
end

function NPanel:GetSize()
    local w, h = self.inst.size
    return w, h
end

return NPanel