--[[
NIndicatorManager
By Nc5xb3
Custom indicator using DS's playerhub.lua + targetindicator.lua as reference
]]

local NPanel = require "widgets/npanel"

local Compatibility = require "util/compatibility"
local NIndicator = require "widgets/nindicator"

local NIndicatorManager = Class(NPanel, function(self)
    NPanel._ctor(self, "NIndicatorManager")
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.owner = Compatibility:ThePlayer()
end)

function NIndicatorManager:AddIndicator(target)
	if not self.indicators then
		self.indicators = {}
	end

	local i = self:AddChild(NIndicator(self.owner, target))
	table.insert(self.indicators, i)

	return i
end

function NIndicatorManager:RemoveIndicator(target)
	if not self.indicators then return end

	local index = nil
	for i,v in pairs(self.indicators) do
		if v and v:GetTarget() == target then
			index = i
			break
		end
	end
	if index then
		local i = table.remove(self.indicators, index)
		if i then i:Kill() end
	end
end

function NIndicatorManager:HasIndicator(target)
	if not self.indicators then return end
	for i,v in pairs(self.indicators) do
		if v and v:GetTarget() == target then
			return true
		end
	end
	return false
end

function NIndicatorManager:GetIndicator(target)
	if not self.indicators then return end
	for i,v in pairs(self.indicators) do
		if v and v:GetTarget() == target then
			return v
		end
	end
	return nil
end

return NIndicatorManager